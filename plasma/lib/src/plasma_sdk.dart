import 'package:flutter/foundation.dart';
import 'package:plasma_core/plasma_core.dart';
import 'package:plasma_bridge/plasma_bridge.dart';
import 'package:plasma_wallet/plasma_wallet.dart';
import 'package:plasma_payment/plasma_payment.dart';

/// Main Plasma SDK singleton class
/// Provides convenient access to all modules and maintains backward compatibility
class Plasma {
  static final Plasma instance = Plasma._internal();
  Plasma._internal();

  // Module instances
  late BridgeModule _bridgeModule;
  late WalletModule _walletModule;
  late PaymentService _paymentService;

  // Cubits
  late BridgeCubit _bridgeCubit;
  late WalletCubit _walletCubit;
  late PaymentCubit _paymentCubit;

  // Configuration
  bool _isInitialized = false;
  late Network _network;
  late NetworkConfig _config;

  // Getters
  Network get network => _network;
  NetworkConfig get config => _config;
  bool get isInitialized => _isInitialized;
  bool get hasWallet => _walletCubit.hasWallet;
  String? get address => _walletCubit.address;

  // Module/Cubit access
  BridgeCubit get bridge => _bridgeCubit;
  WalletCubit get wallet => _walletCubit;
  PaymentCubit get payment => _paymentCubit;

  /// Initialize the Plasma SDK
  Future<void> init({Network network = Network.testnet}) async {
    if (_isInitialized) return;

    _network = network;
    _config = NetworkConfig.getConfig(network);

    debugPrint("🔧 Plasma SDK: ${_config.name}");
    debugPrint("   RPC: ${_config.rpcUrl}");
    debugPrint("   Chain ID: ${_config.chainId}");

    // Initialize modules
    _bridgeModule = BridgeModule();
    _walletModule = WalletModule(_config.rpcUrl);
    _paymentService = PaymentService(
      bridgeModule: _bridgeModule,
      walletModule: _walletModule,
      networkConfig: _config,
    );

    // Initialize cubits
    _bridgeCubit = BridgeCubit(_bridgeModule);
    _walletCubit = WalletCubit(_walletModule);
    _paymentCubit = PaymentCubit(_paymentService);

    // Initialize bridge
    await _bridgeCubit.initialize();

    // Load existing wallet if any
    await _walletModule.load();

    _isInitialized = true;
    debugPrint("✅ Plasma SDK initialized");
  }

  // Convenience API methods (backward compatible)

  /// Create a new wallet
  Future<void> createWallet() async {
    await _walletCubit.createWallet();
  }

  /// Get USDT balance
  Future<String> getBalance() async {
    await _paymentCubit.loadBalance();
    return _paymentCubit.balance;
  }

  /// Send USDT
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
}
