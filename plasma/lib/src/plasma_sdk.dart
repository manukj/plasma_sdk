import 'package:flutter/foundation.dart';
import 'package:plasma_bridge/plasma_bridge.dart';
import 'package:plasma_core/plasma_core.dart';
import 'package:plasma_payment/plasma_payment.dart';
import 'package:plasma_wallet/plasma_wallet.dart';

import 'utils/env_config_resolver.dart';

/// Main Plasma SDK singleton class
/// Provides convenient access to all modules and maintains backward compatibility
class Plasma {
  static final Plasma instance = Plasma._internal();
  Plasma._internal();

  late BridgeModule _bridgeModule;
  late WalletModule _walletModule;
  late PaymentService _paymentService;

  late BridgeCubit _bridgeCubit;
  late WalletCubit _walletCubit;
  late PaymentCubit _paymentCubit;

  bool _isInitialized = false;
  late Network _network;
  late NetworkConfig _config;

  Network get network => _network;
  NetworkConfig get config => _config;
  bool get isInitialized => _isInitialized;
  bool get hasWallet => _walletCubit.hasWallet;
  String? get address => _walletCubit.address;

  BridgeCubit get bridge => _bridgeCubit;
  WalletCubit get wallet => _walletCubit;
  PaymentCubit get payment => _paymentCubit;

  /// Initialize the Plasma SDK
  Future<void> init({
    Network network = Network.testnet,
    String envFile = '.env',
    String? etherscanApiKey,
  }) async {
    if (_isInitialized) return;

    _network = network;
    _config = NetworkConfig.getConfig(network);
    final resolvedEtherscanApiKey =
        await EnvConfigResolver.resolveEtherscanApiKey(
          envFile: envFile,
          overrideKey: etherscanApiKey,
        );

    debugPrint("🔧 Plasma SDK: ${_config.name}");
    debugPrint("   RPC: ${_config.rpcUrl}");
    debugPrint("   Chain ID: ${_config.chainId}");

    _bridgeModule = BridgeModule();
    _walletModule = WalletModule(
      _config.rpcUrl,
      etherscanApiBaseUrl: _config.etherscanApiBaseUrl,
      etherscanApiKey: resolvedEtherscanApiKey,
      usdt0Address: _config.usdt0Address,
      chainId: _config.chainId,
    );
    _paymentService = PaymentService(
      bridgeModule: _bridgeModule,
      walletModule: _walletModule,
      networkConfig: _config,
    );

    _bridgeCubit = BridgeCubit(_bridgeModule);
    _walletCubit = WalletCubit(_walletModule);
    _paymentCubit = PaymentCubit(_paymentService);

    await _bridgeCubit.initialize();

    await _walletModule.load();

    _isInitialized = true;
    debugPrint("✅ Plasma SDK initialized");
  }

  // Convenience API methods (backward compatible)

  /// Create a new wallet
  Future<void> createWallet() async {
    await _walletCubit.createWallet();
  }

  Future<String> getBalance() async {
    await _paymentCubit.loadBalance();
    return _paymentCubit.balance;
  }

  Future<PlasmaTokenTransactionsResponse> getTokenTransactions([
    int number = 10,
  ]) async {
    _ensureInitialized();
    _ensureWalletLoaded();
    return _walletModule.getTokenTransactions(number: number);
  }

  Future<String> sendUSDT({required String to, required String amount}) async {
    await _paymentCubit.sendUSDT(to: to, amount: amount);

    final state = _paymentCubit.state;
    if (state is PaymentSuccess) {
      return state.txHash;
    } else if (state is PaymentError) {
      throw Exception(state.message);
    }

    throw Exception('Unknown payment state');
  }

  /// Delete wallet
  Future<void> deleteWallet() async {
    await _walletModule.clear();
  }

  /// 🧪 TEST ONLY: Load a wallet from a private key for testing
  /// Use this to test full wallet functionality including signing and sending
  /// Example: Plasma.instance.loadTestWallet('0xYourPrivateKeyHere')
  Future<String> loadTestWallet(String privateKey) async {
    final address = await _walletModule.loadTestWallet(privateKey);
    // Trigger cubit to recheck wallet state
    _walletCubit.recheckWallet();
    return address;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('Plasma SDK is not initialized. Call init() first.');
    }
  }

  void _ensureWalletLoaded() {
    if (!hasWallet || address == null) {
      throw StateError('No wallet loaded. Create or load a wallet first.');
    }
  }
}
