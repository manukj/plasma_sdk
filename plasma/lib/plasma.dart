/// Plasma SDK - A Flutter package for blockchain wallet management and network configuration.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart' show EthPrivateKey;

import 'src/api/plasma_api.dart';
import 'src/bridge/bridge_module.dart';
import 'src/config/network_config.dart';
import 'src/wallet/wallet_module.dart';

export 'package:web3dart/web3dart.dart'
    show Credentials, EthPrivateKey, EthereumAddress;

export 'src/api/plasma_api.dart';
export 'src/bridge/bridge_module.dart';
export 'src/config/network_config.dart';
export 'src/wallet/wallet_module.dart';

class Plasma {
  static final Plasma instance = Plasma._internal();
  Plasma._internal();

  late WalletModule wallet;
  late BridgeModule bridge;

  bool _isInitialized = false;
  late Network _network;
  late NetworkConfig _config;

  Network get network => _network;
  NetworkConfig get config => _config;

  String get rpcUrl => _config.rpcUrl;
  String get usdtAddress => _config.usdtAddress;
  String get relayerUrl => _config.relayerUrl;
  int get chainId => _config.chainId;

  @Deprecated('Use network == Network.testnet instead')
  bool get isTestnet => _network == Network.testnet;

  Future<void> init({Network network = Network.testnet}) async {
    if (_isInitialized) return;

    _network = network;
    _config = NetworkConfig.getConfig(network);

    debugPrint("🔧 Plasma SDK: ${_config.name}");
    debugPrint("   RPC: ${_config.rpcUrl}");
    debugPrint("   Chain ID: ${_config.chainId}");

    wallet = WalletModule(_config.rpcUrl);
    await wallet.load();

    bridge = BridgeModule();
    await bridge.init();

    _isInitialized = true;
  }

  bool get hasWallet => wallet.isLoaded;
  String? get address => wallet.address;

  Future<void> createWallet() async {
    await wallet.create();
  }

  Future<void> deleteWallet() async {
    await wallet.clear();
  }

  Future<String> getBalance() async {
    if (!wallet.isLoaded) {
      throw StateError('No wallet loaded. Call createWallet() first.');
    }
    return await wallet.getNativeBalance();
  }

  Future<String> send({
    required String to,
    required String amount,
    String? tokenAddress,
  }) async {
    if (!wallet.isLoaded) {
      throw StateError('No wallet loaded. Call createWallet() first.');
    }

    final credentials = wallet.credentials;
    if (credentials is! EthPrivateKey) {
      throw StateError('Invalid wallet credentials');
    }

    final privateKey =
        '0x${credentials.privateKeyInt.toRadixString(16).padLeft(64, '0')}';
    final from = wallet.address!;
    final token = tokenAddress ?? usdtAddress;

    final signature = await bridge.signGaslessTransfer(
      privateKey: privateKey,
      from: from,
      to: to,
      amount: amount,
      tokenAddress: token,
    );

    if (signature == null || signature.startsWith('ERROR:')) {
      throw Exception('Failed to sign transaction: $signature');
    }

    final signedData = jsonDecode(signature) as Map<String, dynamic>;
    final result = await PlasmaApi.submitGaslessTransfer(signedData);

    return result;
  }

  Future<String> sendUSDT({required String to, required String amount}) async {
    return await send(to: to, amount: amount, tokenAddress: usdtAddress);
  }
}
