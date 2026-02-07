import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'bridge_config.dart';

class BridgeController {
  HeadlessInAppWebView? _headlessWebView;
  InAppWebViewController? _controller;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  InAppWebViewController? get controller => _controller;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint("🌉 BridgeController: Initializing headless WebView...");

    final bundleJs = await rootBundle.loadString(BridgeConfig.bundleAssetPath);

    _headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(data: BridgeConfig.htmlTemplate),
      initialSettings: BridgeConfig.settings,
      onWebViewCreated: (controller) {
        _controller = controller;
        debugPrint("🌉 BridgeController: WebView created");
      },
      onLoadStart: (controller, url) {
        debugPrint("🌉 BridgeController: Loading $url");
      },
      onLoadStop: (controller, url) async {
        debugPrint("✅ BridgeController: HTML loaded, injecting bundle...");
        try {
          await controller.evaluateJavascript(source: bundleJs);
          debugPrint("✅ BridgeController: Bundle injected successfully");
          _isInitialized = true;
        } catch (e) {
          debugPrint("❌ BridgeController: Bundle injection failed - $e");
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint("🔍 JS Console: ${consoleMessage.message}");
      },
      onReceivedError: (controller, request, error) {
        debugPrint("❌ BridgeController: Load error - ${error.description}");
      },
    );

    await _headlessWebView?.run();
    await Future.delayed(BridgeConfig.initializationDelay);

    debugPrint("🌉 BridgeController: Ready");
  }

  Future<T?> evaluateJavascript<T>({required String source}) async {
    if (!_isInitialized || _controller == null) {
      throw StateError('Bridge controller not initialized');
    }

    return await _controller!.evaluateJavascript(source: source);
  }

  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic>? arguments,
  }) async {
    if (!_isInitialized || _controller == null) {
      throw StateError('Bridge controller not initialized');
    }

    return await _controller!.callAsyncJavaScript(
      functionBody: functionBody,
      arguments: arguments ?? {},
    );
  }

  Future<void> dispose() async {
    debugPrint("🌉 BridgeController: Disposing...");
    await _headlessWebView?.dispose();
    _headlessWebView = null;
    _controller = null;
    _isInitialized = false;
  }
}
