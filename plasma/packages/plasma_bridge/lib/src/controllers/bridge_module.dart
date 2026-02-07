import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'bridge_controller.dart';
import '../utils/crypto_utils.dart';

class BridgeModule {
  final BridgeController _controller = BridgeController();

  bool get isInitialized => _controller.isInitialized;

  Future<void> init() async {
    await _controller.initialize();
  }

  Future<String> ping() async {
    if (!isInitialized) {
      return "Error: Bridge not initialized";
    }

    try {
      final result = await _controller.evaluateJavascript(
        source: "window.bridge.ping()",
      );
      return result?.toString() ?? "No response";
    } catch (e) {
      debugPrint("❌ BridgeModule: Ping failed - $e");
      return "Error: $e";
    }
  }

  Future<String?> signGaslessTransfer({
    required String privateKey,
    required String from,
    required String to,
    required String amount,
    required String tokenAddress,
  }) async {
    try {
      final normalizedPrivateKey = CryptoUtils.normalizePrivateKey(privateKey);

      final result = await _controller.callAsyncJavaScript(
        functionBody: """
        return await window.bridge.signGaslessTransfer(
            privateKey,
            from,
            to,
            amount,
            tokenAddress
        );
        """,
        arguments: {
          'privateKey': normalizedPrivateKey,
          'from': from,
          'to': to,
          'amount': amount,
          'tokenAddress': tokenAddress,
        },
      );

      if (result == null || result.error != null) {
        debugPrint(
          "❌ BridgeModule: signGaslessTransfer JS call failed - "
          "${result?.error ?? 'Unknown JS Error'}",
        );
        return "ERROR: ${result?.error ?? 'Unknown JS Error'}";
      }

      final rawValue = result.value?.toString() ?? '';
      if (rawValue.startsWith('ERROR:')) {
        debugPrint(
          "❌ BridgeModule: signGaslessTransfer bridge error - $rawValue",
        );
        return rawValue;
      }

      return rawValue;
    } catch (e) {
      debugPrint("❌ BridgeModule: signGaslessTransfer failed - $e");
      return "ERROR: $e";
    }
  }

  Future<Map<String, dynamic>?> signGaslessUSDT({
    required String privateKey,
    required String from,
    required String to,
    required String amount,
    required String tokenAddress,
  }) async {
    try {
      final raw = await signGaslessTransfer(
        privateKey: privateKey,
        from: from,
        to: to,
        amount: amount,
        tokenAddress: tokenAddress,
      );

      if (raw == null || raw.startsWith('ERROR:')) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  @Deprecated(
    'Use signGaslessUSDT(...) and relay with PlasmaApi.submitGaslessTransfer(...)',
  )
  Future<String> sendUSDT({
    required String privateKey,
    required String to,
    required String amount,
    required String tokenAddress,
  }) async {
    return 'Error: sendUSDT is deprecated. '
        'Use signGaslessUSDT(...) and PlasmaApi.submitGaslessTransfer(...).';
  }

  Future<void> dispose() async {
    await _controller.dispose();
  }
}
