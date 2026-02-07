import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BridgeConfig {
  static const String htmlTemplate = '''
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
  ''';

  static InAppWebViewSettings get settings => InAppWebViewSettings(
    javaScriptEnabled: true,
    useShouldOverrideUrlLoading: false,
    mediaPlaybackRequiresUserGesture: false,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
  );

  static const String bundleAssetPath = 'packages/plasma/assets/www/bundle.js';
  static const Duration initializationDelay = Duration(milliseconds: 1000);
}
