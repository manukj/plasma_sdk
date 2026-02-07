import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BridgeModule {
  HeadlessInAppWebView? _headlessWebView;
  InAppWebViewController? _controller;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _normalizePrivateKey(String privateKey) {
    final trimmed = privateKey.trim();
    final hexBody = trimmed.startsWith('0x') || trimmed.startsWith('0X')
        ? trimmed.substring(2)
        : trimmed;

    if (hexBody.isEmpty || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexBody)) {
      throw const FormatException('Private key must be a valid hex string');
    }

    if (hexBody.length > 64) {
      throw const FormatException(
        'Private key must be 32 bytes (64 hex chars)',
      );
    }

    return '0x${hexBody.padLeft(64, '0').toLowerCase()}';
  }

  /// Initialize the headless WebView with the bundled JavaScript
  Future<void> init() async {
    if (_isInitialized) return;

    debugPrint("🌉 BridgeModule: Initializing headless WebView...");

    // Load the bundled JavaScript from assets
    final bundleJs = await rootBundle.loadString(
      'packages/plasma/assets/www/bundle.js',
    );
    _headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(
        data: '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Plasma Bridge</title>
</head>
<body>
    <h1>Plasma Bridge (Offline Mode)</h1>
    <!-- bundle.js will be injected via evaluateJavascript -->
</body>
</html>
        ''',
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
        debugPrint("🌉 BridgeModule: WebView created");
      },
      onLoadStart: (controller, url) {
        debugPrint("🌉 BridgeModule: Loading $url");
      },
      onLoadStop: (controller, url) async {
        debugPrint("✅ BridgeModule: HTML loaded, injecting bundle...");
        try {
          // Inject the bundle
          await controller.evaluateJavascript(source: bundleJs);
          debugPrint("✅ BridgeModule: Bundle injected successfully");
          _isInitialized = true;
        } catch (e) {
          debugPrint("❌ BridgeModule: Bundle injection failed - $e");
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        // Forward JS console.log to Flutter debug console
        debugPrint("🔍 JS Console: ${consoleMessage.message}");
      },
      onReceivedError: (controller, request, error) {
        debugPrint("❌ BridgeModule: Load error - ${error.description}");
      },
    );

    await _headlessWebView?.run();

    // Wait a bit for the page to fully initialize
    await Future.delayed(const Duration(milliseconds: 1000));

    debugPrint("🌉 BridgeModule: Ready");
  }

  /// Ping the bridge to verify communication
  Future<String> ping() async {
    if (!_isInitialized || _controller == null) {
      return "Error: Bridge not initialized";
    }

    try {
      final result = await _controller!.evaluateJavascript(
        source: "window.bridge.ping()",
      );

      return result?.toString() ?? "No response";
    } catch (e) {
      debugPrint("❌ BridgeModule: Ping failed - $e");
      return "Error: $e";
    }
  }

  /// Generates the EIP-3009 signature payload as a raw JSON string.
  Future<String?> signGaslessTransfer({
    required String privateKey,
    required String from,
    required String to,
    required String amount,
    required String tokenAddress,
  }) async {
    if (!_isInitialized || _controller == null) {
      return "ERROR: Bridge not initialized";
    }

    try {
      final normalizedPrivateKey = _normalizePrivateKey(privateKey);

      final result = await _controller!.callAsyncJavaScript(
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

  /// Generates the EIP-3009 signature payload for a gasless USDT transfer.
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

  /// Clean up resources
  Future<void> dispose() async {
    debugPrint("🌉 BridgeModule: Disposing...");
    await _headlessWebView?.dispose();
    _headlessWebView = null;
    _controller = null;
    _isInitialized = false;
  }
}
