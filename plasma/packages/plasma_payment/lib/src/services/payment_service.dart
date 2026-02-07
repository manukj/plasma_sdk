import 'package:plasma_bridge/plasma_bridge.dart';
import 'package:plasma_core/plasma_core.dart';
import 'package:plasma_wallet/plasma_wallet.dart';
import 'package:web3dart/web3dart.dart';

/// Service for payment operations
class PaymentService {
  final BridgeModule _bridgeModule;
  final WalletModule _walletModule;
  final NetworkConfig _networkConfig;

  PaymentService({
    required BridgeModule bridgeModule,
    required WalletModule walletModule,
    required NetworkConfig networkConfig,
  })  : _bridgeModule = bridgeModule,
        _walletModule = walletModule,
        _networkConfig = networkConfig;

  /// Get USDT balance
  Future<String> getBalance() async {
    if (!_walletModule.isLoaded) {
      throw StateError('No wallet available');
    }

    // For now, return native balance as USDT balance is similar flow
    // TODO: Implement actual USDT balance query via bridge
    return await _walletModule.getNativeBalance();
  }

  /// Send USDT to an address
  Future<String> sendUSDT({
    required String to,
    required String amount,
  }) async {
    if (!_walletModule.isLoaded) {
      throw StateError('No wallet available');
    }

    final credentials = _walletModule.credentials;
    if (credentials is! EthPrivateKey) {
      throw StateError('Invalid wallet credentials');
    }

    // Get private key as hex string
    final privateKey =
        '0x${credentials.privateKeyInt.toRadixString(16).padLeft(64, '0')}';
    final from = _walletModule.address!;

    // Sign the transaction
    final signedTx = await _bridgeModule.signGaslessUSDT(
      privateKey: privateKey,
      from: from,
      to: to,
      amount: amount,
      tokenAddress: _networkConfig.usdtAddress,
    );

    if (signedTx == null) {
      throw Exception('Failed to sign transaction');
    }

    // Submit to relayer
    final txHash = await _submitToRelayer(signedTx);
    return txHash;
  }

  Future<String> _submitToRelayer(Map<String, dynamic> signedTx) async {
    // TODO: Implement actual HTTP call to relayer
    // For now, return a mock tx hash
    return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
  }
}
