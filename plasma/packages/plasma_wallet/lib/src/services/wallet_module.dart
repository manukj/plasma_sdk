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
  late EthereumAddress _usdt0ContractAddress;
  late DeployedContract _usdt0Contract;
  late ContractFunction _usdt0BalanceOfFunction;
  late ContractFunction _usdt0DecimalsFunction;
  final _storage = const FlutterSecureStorage();
  final String _storageKey = 'plasma_private_key';

  Credentials? _credentials;
  EthereumAddress? _address;
  static const String _erc20BalanceAbi = '''
[
  {
    "constant": true,
    "inputs": [{"name": "account", "type": "address"}],
    "name": "balanceOf",
    "outputs": [{"name": "", "type": "uint256"}],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "decimals",
    "outputs": [{"name": "", "type": "uint8"}],
    "stateMutability": "view",
    "type": "function"
  }
]
''';

  WalletModule(
    String rpcUrl, {
    required String etherscanApiBaseUrl,
    required String etherscanApiKey,
    required String usdt0Address,
    required int chainId,
  }) {
    _client = Web3Client(rpcUrl, Client());
    _usdt0ContractAddress = EthereumAddress.fromHex(usdt0Address);
    _usdt0Contract = DeployedContract(
      ContractAbi.fromJson(_erc20BalanceAbi, 'USDT0'),
      _usdt0ContractAddress,
    );
    _usdt0BalanceOfFunction = _usdt0Contract.function('balanceOf');
    _usdt0DecimalsFunction = _usdt0Contract.function('decimals');
    _tokenTransactionsRepository = TokenTransactionsRepositoryImpl(
      TokenTransactionsRemoteDataSource(
        apiBaseUrl: etherscanApiBaseUrl,
        apiKey: etherscanApiKey,
        contractAddress: usdt0Address,
        chainId: chainId,
      ),
    );
  }

  String? get address => _address?.hex;
  bool get isLoaded => _credentials != null;
  Credentials? get credentials => _credentials;

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

  ///  Create a new random wallet & save it
  Future<String> create() async {
    var rng = Random.secure();
    var key = EthPrivateKey.createRandom(rng);

    final keyHex = key.privateKeyInt.toRadixString(16).padLeft(64, '0');

    await _storage.write(key: _storageKey, value: keyHex);

    _credentials = key;
    _address = key.address;

    return _address!.hex;
  }

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

  Future<String> getGasTokenBalance() async {
    if (_address == null) return "0.0000";

    try {
      final balance = await _client.getBalance(_address!);

      double formatted = balance.getValueInUnit(EtherUnit.ether).toDouble();
      return formatted.toStringAsFixed(4);
    } catch (e) {
      return "0.0000";
    }
  }

  @Deprecated('Use getGasTokenBalance() instead.')
  Future<String> getNativeBalance() async => getGasTokenBalance();

  Future<String> getStableTokenBalance() async {
    if (_address == null) return "0.0000";

    try {
      final balanceResult = await _client.call(
        contract: _usdt0Contract,
        function: _usdt0BalanceOfFunction,
        params: [_address!],
      );

      if (balanceResult.isEmpty || balanceResult.first is! BigInt) {
        return "0.0000";
      }

      final rawBalance = balanceResult.first as BigInt;
      final decimals = await _resolveStableTokenDecimals();
      return _formatTokenBalance(rawBalance, decimals);
    } catch (e) {
      return "0.0000";
    }
  }

  Future<int> _resolveStableTokenDecimals() async {
    try {
      final decimalsResult = await _client.call(
        contract: _usdt0Contract,
        function: _usdt0DecimalsFunction,
        params: const [],
      );

      if (decimalsResult.isEmpty) return 6;
      final rawDecimals = decimalsResult.first;
      if (rawDecimals is BigInt) return rawDecimals.toInt();
      if (rawDecimals is int) return rawDecimals;
      return 6;
    } catch (_) {
      return 6;
    }
  }

  String _formatTokenBalance(BigInt rawBalance, int decimals) {
    if (rawBalance == BigInt.zero) return "0.0000";

    final safeDecimals = decimals < 0 ? 0 : decimals;
    if (safeDecimals == 0) return rawBalance.toString();

    final base = BigInt.from(10).pow(safeDecimals);
    final whole = rawBalance ~/ base;
    final fraction = (rawBalance % base).toString().padLeft(safeDecimals, '0');
    final precision = safeDecimals >= 4 ? 4 : safeDecimals;
    if (precision == 0) return whole.toString();

    final trimmedFraction = fraction.substring(0, precision);
    return '$whole.$trimmedFraction';
  }

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
