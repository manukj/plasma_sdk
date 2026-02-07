# Plasma SDK

A powerful Flutter package for blockchain wallet management with beautiful UI components and seamless gasless transactions on the Plasma network.

---

## Features

✅ **Self-Custodial Wallet** - Secure wallet creation and management  
✅ **Gasless Transactions** - Send tokens without gas fees  
✅ **Beautiful UI Widgets** - Pre-built, customizable components  
✅ **Network Support** - Testnet and Mainnet configurations  
✅ **Secure Storage** - Keychain/Keystore integration  
✅ **Simple API** - High-level convenience methods  

---

## Quick Start

### 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  plasma: ^0.0.1
```

Then run:
```bash
flutter pub get
```

---

### 2. Initialize SDK

```dart
import 'package:plasma/plasma.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize on Testnet
  await Plasma.instance.init(network: Network.testnet);
  
  runApp(MyApp());
}
```

---

### 3. Create Wallet with UI

```dart
// Show beautiful wallet creation sheet
await showCreateWalletSheet(context);
```

**That's it!** Your users now have a beautiful wallet creation experience.

---

## Usage Examples

### Create Wallet

```dart
// Using UI widget (Recommended)
await showCreateWalletSheet(context);

// Or programmatically
await Plasma.instance.createWallet();
```

### Check Wallet Status

```dart
if (Plasma.instance.hasWallet) {
  String? address = Plasma.instance.address;
  print('Wallet: $address');
}
```

### Get Balance

```dart
String balance = await Plasma.instance.getBalance();
print('Balance: $balance XPL');
```

### Send USDT

```dart
try {
  String result = await Plasma.instance.sendUSDT(
    to: '0xRecipientAddress',
    amount: '10.5',
  );
  print('Success: $result');
} catch (e) {
  print('Error: $e');
}
```

---

## UI Components

### Wallet Creation Sheet

Three-state flow with beautiful animations:
1. **Initial** - Onboarding with features
2. **Loading** - Wallet creation animation  
3. **Success** - Wallet address display

```dart
PlasmaButton(
  text: 'Get Started',
  icon: Icons.account_balance_wallet,
  onPressed: () => showCreateWalletSheet(context),
)
```

See [UI Documentation](document/UI/ui_doc.md) for details.

---

## Documentation

- **[API Reference](document/API.md)** - Complete API documentation
- **[UI Widgets Guide](document/UI/ui_doc.md)** - UI components and usage
- **[Example App](example/lib/main.dart)** - Full working example

---

## Requirements

- Flutter SDK: `>=3.9.2`
- Dart SDK: `>=3.0.0`
- Platforms: iOS, Android

---

## Security

🔒 **Private keys never leave your device**  
- Stored in iOS Keychain / Android Keystore
- Hardware-backed encryption when available
- No server-side key storage

---

## Example App

Run the example app:

```bash
cd example
flutter run
```

---

## License

MIT License - See LICENSE file for details

---

**Built with ❤️ for the Plasma ecosystem**
