# Plasma SDK

A Flutter package that enables seamless communication between Flutter and a hidden JavaScript environment using a headless WebView.

## Features

- 🚀 **Headless WebView**: Execute JavaScript without visible UI elements
- 🔄 **Bidirectional Communication**: Call JavaScript functions from Flutter and receive results
- 📱 **Cross-Platform**: Works on iOS, Android, and macOS
- 🛠️ **Simple API**: Easy-to-use SDK with minimal setup

## Getting Started

### Installation

Add `plasma` to your `pubspec.yaml`:

```yaml
dependencies:
  plasma:
    path: ../plasma  # Update with your actual path
```

### Usage

1. **Initialize the SDK**

```dart
import 'package:plasma/plasma.dart';

final sdk = PlasmaSDK();
await sdk.initialize();
```

2. **Call JavaScript Functions**

```dart
// Use the built-in getHelloWorld() function
final message = await sdk.getHelloWorld();
print(message); // "Hello World from JS World"

// Or execute custom JavaScript
final result = await sdk.evaluateJavascript('2 + 2');
print(result); // 4
```

3. **Clean Up**

```dart
await sdk.dispose();
```

## Example

See the `example` directory for a complete working example.

## How It Works

Plasma SDK uses `flutter_inappwebview` to create a headless WebView that loads an HTML file containing your JavaScript code. The SDK provides methods to execute JavaScript and retrieve results, enabling seamless integration between Flutter and JavaScript environments.

## Requirements

- **iOS**: iOS 12.0 or higher
- **Android**: API level 19 or higher
- **macOS**: macOS 10.14 or higher

## License

MIT License
