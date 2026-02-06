import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BridgeModule {
  HeadlessInAppWebView? _headlessWebView;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the headless WebView with the bridge HTML
  Future<void> init() async {
    if (_isInitialized) return;

    debugPrint("🌉 BridgeModule: Initializing headless WebView...");

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
    <script>
        console.log("🌉 Plasma Bridge: Initializing...");

        // Global Bridge Object
        window.bridge = {
            ping: function() {
                console.log("🏓 Bridge: ping() called from Dart");
                return "pong";
            }
        };

        console.log("✅ Plasma Bridge: Loaded successfully");
        console.log("📡 Bridge API available at window.bridge");
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
    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint("🌉 BridgeModule: Ready");
  }

  /// Ping the bridge to verify communication
  Future<String> ping() async {
    if (!_isInitialized || _headlessWebView == null) {
      return "Error: Bridge not initialized";
    }

    try {
      final result = await _headlessWebView!.webViewController
          ?.evaluateJavascript(source: "window.bridge.ping()");

      return result?.toString() ?? "No response";
    } catch (e) {
      debugPrint("❌ BridgeModule: Ping failed - $e");
      return "Error: $e";
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    debugPrint("🌉 BridgeModule: Disposing...");
    await _headlessWebView?.dispose();
    _headlessWebView = null;
    _isInitialized = false;
  }
}
