import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../data/token_transactions_remote_data_source.dart';
import '../models/plasma_token_transactions_response.dart';
import '../repositories/token_transactions_repository.dart';
import '../repositories/token_transactions_repository_impl.dart';

class WalletModule {
  late Web3Client _client;
  late TokenTransactionsRepository _tokenTransactionsRepository;
  final _storage = const FlutterSecureStorage();
  final String _storageKey = 'plasma_private_key';

  // State
  Credentials? _credentials;
  EthereumAddress? _address;

  // Constructor
  WalletModule(
    String rpcUrl, {
    required String etherscanApiBaseUrl,
    required String etherscanApiKey,
    required String usdt0Address,
    required int chainId,
  }) {
    _client = Web3Client(rpcUrl, Client());
    _tokenTransactionsRepository = TokenTransactionsRepositoryImpl(
      TokenTransactionsRemoteDataSource(
        apiBaseUrl: etherscanApiBaseUrl,
        apiKey: etherscanApiKey,
        contractAddress: usdt0Address,
        chainId: chainId,
      ),
    );
  }

  // --- GETTERS ---
  String? get address => _address?.hex;
  bool get isLoaded => _credentials != null;
  Credentials? get credentials => _credentials;

  // --- KEY MANAGEMENT ---

  /// 1. Load existing wallet from secure storage
  Future<bool> load() async {
    final privateKey = await _storage.read(key: _storageKey);
    if (privateKey != null) {
      _credentials = EthPrivateKey.fromHex(privateKey);
      _address = _credentials!.address;
      return true;
    }
    return false;
  }

  /// 2. Create a new random wallet & save it
  Future<String> create() async {
    var rng = Random.secure();
    var key = EthPrivateKey.createRandom(rng);

    // Save hex string to secure storage
    final keyHex = key.privateKeyInt.toRadixString(16).padLeft(64, '0');

    await _storage.write(key: _storageKey, value: keyHex);

    _credentials = key;
    _address = key.address;

    return _address!.hex;
  }

  /// 3. Delete wallet (Logout)
  Future<void> clear() async {
    await _storage.delete(key: _storageKey);
    _credentials = null;
    _address = null;
  }

  /// 🧪 TEST ONLY: Load a wallet from a private key for testing
  /// This allows full wallet functionality including signing
  Future<String> loadTestWallet(String privateKeyHex) async {
    // Normalize the private key (handle 0x prefix, padding, etc)
    final normalized = privateKeyHex.trim();
    final hexBody = normalized.startsWith('0x') || normalized.startsWith('0X')
        ? normalized.substring(2)
        : normalized;

    // Create credentials from private key
    _credentials = EthPrivateKey.fromHex('0x${hexBody.padLeft(64, '0')}');
    _address = _credentials!.address;

    return _address!.hex;
  }

  // --- BLOCKCHAIN DATA ---

  /// 4. Get Native Balance (XPL)
  Future<String> getNativeBalance() async {
    if (_address == null) return "0.0000";

    try {
      final balance = await _client.getBalance(_address!);

      // Convert Wei to Ether (18 decimals for XPL)
      double formatted = balance.getValueInUnit(EtherUnit.ether).toDouble();
      return formatted.toStringAsFixed(4);
    } catch (e) {
      // Error reading balance, return 0
      return "0.0000";
    }
  }

  /// 5. Get USDT0 token transactions for current wallet address
  Future<PlasmaTokenTransactionsResponse> getTokenTransactions({
    int number = 10,
  }) async {
    if (_address == null) {
      throw StateError('No wallet available');
    }

    return _tokenTransactionsRepository.getAddressTransactions(
      address: _address!.hex,
      number: number,
    );
  }
}
