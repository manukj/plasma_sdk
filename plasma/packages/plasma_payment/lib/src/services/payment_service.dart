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

  /// Get native gas token balance (XPL)
  Future<String> getGasTokenBalance() async {
    if (!_walletModule.isLoaded) {
      throw StateError('No wallet available');
    }

    return await _walletModule.getGasTokenBalance();
  }

  /// Get stable token balance (USDT0)
  Future<String> getStableTokenBalance() async {
    if (!_walletModule.isLoaded) {
      throw StateError('No wallet available');
    }

    return await _walletModule.getStableTokenBalance();
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
      tokenAddress: _networkConfig.usdt0Address,
      rpcUrl: _networkConfig.rpcUrl,
    );

    if (signedTx == null) {
      throw Exception('Failed to sign transaction');
    }

    final txHash = _extractTransactionHash(signedTx);
    if (txHash == null || txHash.isEmpty) {
      throw Exception('Transaction response missing txHash');
    }
    return txHash;
  }

  String? _extractTransactionHash(Map<String, dynamic> response) {
    final txHash = response['txHash'];
    if (txHash is String && txHash.isNotEmpty) return txHash;
    final hash = response['hash'];
    if (hash is String && hash.isNotEmpty) return hash;
    return null;
  }
}
