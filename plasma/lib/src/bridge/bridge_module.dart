import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BridgeModule {
  HeadlessInAppWebView? _headlessWebView;
  InAppWebViewController? _controller;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the headless WebView with the bundled JavaScript
  Future<void> init() async {
    if (_isInitialized) return;

    debugPrint("🌉 BridgeModule: Initializing headless WebView...");

    // Load the bundled JavaScript from assets
    final bundleJs = await rootBundle.loadString('assets/www/bundle.js');

    _headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(
        data:
            '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Plasma Bridge</title>
</head>
<body>
    <h1>Plasma Bridge (Offline Mode)</h1>
    <script>
$bundleJs
    </script>
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
        debugPrint("✅ BridgeModule: WebView loaded successfully");
        _isInitialized = true;
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

  /// Send USDT transaction
  Future<String> sendUSDT({
    required String privateKey,
    required String to,
    required String amount,
    required String tokenAddress,
  }) async {
    if (!_isInitialized || _controller == null) {
      return "Error: Bridge not initialized";
    }

    try {
      final result = await _controller!.callAsyncJavaScript(
        functionBody: """
        return await window.bridge.sendUSDT(
            arguments[0], // privateKey
            arguments[1], // to
            arguments[2], // amount
            arguments[3]  // tokenAddress
        );
        """,
        arguments: {'0': privateKey, '1': to, '2': amount, '3': tokenAddress},
      );

      if (result == null || result.error != null) {
        return "Error: ${result?.error ?? 'Unknown JS Error'}";
      }

      return result.value.toString();
    } catch (e) {
      debugPrint("❌ BridgeModule: sendUSDT failed - $e");
      return "Error: $e";
    }
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
