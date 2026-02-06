import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// The Plasma SDK provides a bridge between Flutter and a headless JavaScript environment.
///
/// This SDK uses an invisible WebView to execute JavaScript code and communicate
/// the results back to Flutter.
class PlasmaSDK {
  HeadlessInAppWebView? _headlessWebView;
  InAppWebViewController? _webViewController;
  final Completer<void> _initCompleter = Completer<void>();
  bool _isInitialized = false;

  /// Initializes the Plasma SDK by setting up a headless WebView.
  ///
  /// This method must be called before any other SDK methods.
  /// The WebView loads a local HTML file from the assets directory.
  ///
  /// Returns a [Future] that completes when the SDK is ready to use.
  Future<void> initialize() async {
    if (_isInitialized) {
      return _initCompleter.future;
    }

    _isInitialized = true;

    // Load the HTML content from assets
    final String htmlContent = await rootBundle.loadString(
      'packages/plasma/assets/www/index.html',
    );

    // Create a headless WebView (not visible to the user)
    _headlessWebView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
      onWebViewCreated: (controller) async {
        _webViewController = controller;
        debugPrint('Plasma: WebView created');

        // Load the HTML content
        await controller.loadData(
          data: htmlContent,
          baseUrl: WebUri('https://plasma.local'),
          mimeType: 'text/html',
          encoding: 'utf-8',
        );
      },
      onLoadStop: (controller, url) async {
        debugPrint('Plasma: Page loaded - $url');
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete();
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('Plasma JS Console: ${consoleMessage.message}');
      },
      onReceivedError: (controller, request, error) {
        debugPrint('Plasma Error: ${error.description}');
        if (!_initCompleter.isCompleted) {
          _initCompleter.completeError(
            Exception('Failed to load: ${error.description}'),
          );
        }
      },
    );

    // Start the headless WebView
    await _headlessWebView!.run();

    // Wait for the WebView to finish loading
    return _initCompleter.future;
  }

  /// Calls the JavaScript `getHelloWorld()` function and returns its result.
  ///
  /// Returns a [Future<String>] containing the greeting from the JavaScript environment.
  ///
  /// Throws an [Exception] if the SDK is not initialized or if the JavaScript
  /// execution fails.
  Future<String> getHelloWorld() async {
    if (!_isInitialized || _webViewController == null) {
      throw Exception('PlasmaSDK is not initialized. Call initialize() first.');
    }

    // Wait for initialization to complete
    await _initCompleter.future;

    try {
      // Execute JavaScript and get the result
      final result = await _webViewController!.evaluateJavascript(
        source: 'getHelloWorld()',
      );

      if (result == null) {
        throw Exception('JavaScript function returned null');
      }

      return result.toString();
    } catch (e) {
      debugPrint('Plasma: Error executing JavaScript - $e');
      rethrow;
    }
  }

  /// Executes arbitrary JavaScript code in the hidden WebView.
  ///
  /// [source] The JavaScript code to execute.
  ///
  /// Returns a [Future] containing the result of the JavaScript execution.
  ///
  /// Throws an [Exception] if the SDK is not initialized.
  Future<dynamic> evaluateJavascript(String source) async {
    if (!_isInitialized || _webViewController == null) {
      throw Exception('PlasmaSDK is not initialized. Call initialize() first.');
    }

    // Wait for initialization to complete
    await _initCompleter.future;

    try {
      return await _webViewController!.evaluateJavascript(source: source);
    } catch (e) {
      debugPrint('Plasma: Error executing JavaScript - $e');
      rethrow;
    }
  }

  /// Disposes of the SDK resources.
  ///
  /// Call this method when you're done using the SDK to clean up resources.
  Future<void> dispose() async {
    await _headlessWebView?.dispose();
    _headlessWebView = null;
    _webViewController = null;
    _isInitialized = false;
  }
}
