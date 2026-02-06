/// Plasma SDK - A Flutter package for blockchain wallet management and network configuration.
library;

import 'package:flutter/foundation.dart';

import 'src/bridge/bridge_module.dart';
import 'src/wallet/wallet_module.dart';

export 'src/bridge/bridge_module.dart';
export 'src/wallet/wallet_module.dart';

class Plasma {
  // Singleton Instance
  static final Plasma instance = Plasma._internal();
  Plasma._internal();

  // Public Modules
  late WalletModule wallet;
  late BridgeModule bridge;

  // Configuration State
  bool _isInitialized = false;
  bool get isTestnet => _isTestnet;
  late bool _isTestnet;
  late String rpcUrl;

  /// Initialize the SDK
  /// [isTestnet]: true = Plasma Testnet, false = Plasma Mainnet
  Future<void> init({bool isTestnet = false}) async {
    if (_isInitialized) return;

    _isTestnet = isTestnet;

    // 1. Network Configuration
    if (isTestnet) {
      rpcUrl = "https://testnet-rpc.plasma.to";
      debugPrint("🔧 Plasma SDK: Testnet Mode");
    } else {
      rpcUrl = "https://rpc.plasma.to";
      debugPrint("🚀 Plasma SDK: Mainnet Mode");
    }

    // 2. Initialize Wallet with the correct RPC
    wallet = WalletModule(rpcUrl);

    // 3. Try to load saved wallet
    await wallet.load();

    // 4. Initialize Bridge Module
    bridge = BridgeModule();
    await bridge.init();

    _isInitialized = true;
  }
}
