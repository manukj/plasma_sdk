# Plasma SDK - API Reference

Complete API documentation for the Plasma Flutter SDK.

---

## Table of Contents

- [Plasma Core](#plasma-core)
- [Wallet Module](#wallet-module)
- [Bridge Module](#bridge-module)
- [Network Configuration](#network-configuration)
- [UI Widgets](#ui-widgets)
- [API Service](#api-service)

---

## Plasma Core

### `Plasma.instance`

Singleton instance for accessing the SDK.

```dart
final plasma = Plasma.instance;
```

### Initialization

#### `init({Network network})`

Initialize the Plasma SDK with network configuration.

```dart
await Plasma.instance.init(network: Network.testnet);
```

**Parameters:**
- `network` (optional): `Network.testnet` or `Network.mainnet` (default: `Network.testnet`)

**Returns:** `Future<void>`

---

### Properties

#### `network`
Current network configuration.
- **Type:** `Network`
- **Read-only**

#### `config`
Current network configuration object.
- **Type:** `NetworkConfig`
- **Read-only**

#### `isInitialized`
Whether SDK has been initialized.
- **Type:** `bool`
- **Read-only**

#### `hasWallet`
Whether a wallet exists.
- **Type:** `bool`
- **Read-only**

#### `address`
Current wallet address.
- **Type:** `String?`
- **Read-only**

#### `rpcUrl`
Current network RPC URL.
- **Type:** `String`
- **Read-only**

#### `usdtAddress`
USDT token contract address for current network.
- **Type:** `String`
- **Read-only**

#### `relayerUrl`
Relayer service URL for current network.
- **Type:** `String`
- **Read-only**

#### `chainId`
Chain ID for current network.
- **Type:** `int`
- **Read-only**

---

### High-Level Methods

#### `createWallet()`

Create a new wallet.

```dart
await Plasma.instance.createWallet();
```

**Returns:** `Future<void>`

**Throws:** `Exception` if wallet creation fails

---

#### `deleteWallet()`

Delete the current wallet.

```dart
await Plasma.instance.deleteWallet();
```

**Returns:** `Future<void>`

---

#### `getBalance()`

Get native token balance (XPL).

```dart
String balance = await Plasma.instance.getBalance();
```

**Returns:** `Future<String>` - Balance as string

**Throws:** `StateError` if no wallet loaded

---

#### `send({required String to, required String amount, String? tokenAddress})`

Send tokens (default: USDT) with gasless transaction.

```dart
String txHash = await Plasma.instance.send(
  to: '0xRecipientAddress',
  amount: '10.5',
  tokenAddress: '0xTokenAddress', // Optional
);
```

**Parameters:**
- `to` (required): Recipient address
- `amount` (required): Amount to send as string
- `tokenAddress` (optional): Token contract address (defaults to USDT)

**Returns:** `Future<String>` - Transaction result

**Throws:** 
- `StateError` if no wallet loaded
- `Exception` if transaction fails

---

#### `sendUSDT({required String to, required String amount})`

Convenience method to send USDT.

```dart
String txHash = await Plasma.instance.sendUSDT(
  to: '0xRecipientAddress',
  amount: '10.5',
);
```

**Parameters:**
- `to` (required): Recipient address
- `amount` (required): Amount to send as string

**Returns:** `Future<String>` - Transaction result

---

## Wallet Module

Access via `Plasma.instance.wallet`

### Properties

#### `isLoaded`
Whether wallet is loaded.
- **Type:** `bool`
- **Read-only**

#### `address`
Wallet address.
- **Type:** `String?`
- **Read-only**

#### `credentials`
Wallet credentials.
- **Type:** `Credentials?`
- **Read-only**

---

### Methods

#### `create()`

Create a new wallet.

```dart
await Plasma.instance.wallet.create();
```

**Returns:** `Future<void>`

---

#### `load()`

Load existing wallet from secure storage.

```dart
await Plasma.instance.wallet.load();
```

**Returns:** `Future<void>`

---

#### `clear()`

Delete wallet from secure storage.

```dart
await Plasma.instance.wallet.clear();
```

**Returns:** `Future<void>`

---

#### `getNativeBalance()`

Get native token balance.

```dart
String balance = await Plasma.instance.wallet.getNativeBalance();
```

**Returns:** `Future<String>` - Balance as string

---

## Bridge Module

Access via `Plasma.instance.bridge`

### Methods

#### `init()`

Initialize the JavaScript bridge.

```dart
await Plasma.instance.bridge.init();
```

**Returns:** `Future<void>`

---

#### `ping()`

Test bridge connectivity.

```dart
String response = await Plasma.instance.bridge.ping();
// Returns: "pong"
```

**Returns:** `Future<String>`

---

#### `signGaslessTransfer({...})`

Sign a gasless transfer transaction.

```dart
String? signature = await Plasma.instance.bridge.signGaslessTransfer(
  privateKey: '0x...',
  from: '0xSenderAddress',
  to: '0xRecipientAddress',
  amount: '10.5',
  tokenAddress: '0xTokenAddress',
);
```

**Parameters:**
- `privateKey` (required): Private key with 0x prefix
- `from` (required): Sender address
- `to` (required): Recipient address
- `amount` (required): Amount as string
- `tokenAddress` (required): Token contract address

**Returns:** `Future<String?>` - JSON string with signature data or error

---

#### `dispose()`

Clean up bridge resources.

```dart
await Plasma.instance.bridge.dispose();
```

**Returns:** `Future<void>`

---

## Network Configuration

### `Network` Enum

```dart
enum Network {
  testnet,
  mainnet,
}
```

### `NetworkConfig` Class

#### `NetworkConfig.getConfig(Network network)`

Get configuration for a network.

```dart
NetworkConfig config = NetworkConfig.getConfig(Network.testnet);
```

**Returns:** `NetworkConfig`

---

#### Properties

- `name`: Network name (String)
- `rpcUrl`: RPC endpoint URL (String)
- `usdtAddress`: USDT contract address (String)
- `relayerUrl`: Relayer service URL (String)
- `chainId`: Chain ID (int)

---

## UI Widgets

### `showCreateWalletSheet(BuildContext context)`

Display wallet creation bottom sheet.

```dart
await showCreateWalletSheet(context);
```

**Parameters:**
- `context` (required): BuildContext

**Returns:** `Future<void>`

**See:** [UI Documentation](document/UI/ui_doc.md)

---

### `PlasmaButton`

Primary action button.

```dart
PlasmaButton(
  text: 'Create Wallet',
  icon: Icons.account_balance_wallet,
  onPressed: () {},
  isLoading: false,
  isFullWidth: true,
)
```

**Properties:**
- `text` (required): Button text
- `onPressed`: Callback function
- `isLoading`: Show loading spinner (default: false)
- `icon`: Leading icon
- `isFullWidth`: Full width button (default: true)

---

### `PlasmaLoadingWidget`

Animated loading indicator.

```dart
PlasmaLoadingWidget(
  message: 'Creating your secure wallet...',
  subtitle: 'SECURING KEYS',
)
```

**Properties:**
- `message`: Main loading message
- `subtitle`: Optional subtitle text

---

### `PlasmaFeatureCard`

Feature highlight card.

```dart
PlasmaFeatureCard(
  icon: Icons.security,
  title: 'Military-grade Security',
  description: 'Your keys never leave your device.',
)
```

**Properties:**
- `icon` (required): Feature icon
- `title` (required): Feature title
- `description` (required): Feature description

---

## API Service

### `PlasmaApi`

Static methods for API calls.

#### `submitGaslessTransfer(Map<String, dynamic> signedData)`

Submit signed transaction to relayer.

```dart
String result = await PlasmaApi.submitGaslessTransfer(signedData);
```

**Parameters:**
- `signedData` (required): Signed transaction data

**Returns:** `Future<String>` - Transaction result

**Throws:** `Exception` on API error

---

## PlasmaTheme

Design system constants.

### Colors

```dart
PlasmaTheme.primary        // #1E4D4D
PlasmaTheme.success        // #10B981
PlasmaTheme.error          // #EF4444
PlasmaTheme.textPrimary    // #101828
PlasmaTheme.textSecondary  // #475467
PlasmaTheme.textTertiary   // #98A2B3
PlasmaTheme.background     // #F9FAFB
PlasmaTheme.border         // #E4E7EC
```

### Spacing

```dart
PlasmaTheme.spacingXs      // 4.0
PlasmaTheme.spacingSm      // 8.0
PlasmaTheme.spacingMd      // 12.0
PlasmaTheme.spacingLg      // 16.0
PlasmaTheme.spacingXl      // 24.0
PlasmaTheme.spacing2xl     // 32.0
PlasmaTheme.spacing3xl     // 48.0
```

### Border Radius

```dart
PlasmaTheme.radiusSm       // 8.0
PlasmaTheme.radiusMd       // 12.0
PlasmaTheme.radiusLg       // 16.0
PlasmaTheme.radiusXl       // 20.0
PlasmaTheme.radius2xl      // 24.0
```

---

## Error Handling

All async methods may throw exceptions. Wrap in try-catch:

```dart
try {
  await Plasma.instance.createWallet();
} catch (e) {
  print('Error: $e');
}
```

Common errors:
- `StateError`: Operation requires wallet but none exists
- `Exception`: General operation failure
- Network errors from API calls

---

## Type Exports

Commonly used types are exported from `package:plasma/plasma.dart`:

- `Credentials` - from web3dart
- `EthPrivateKey` - from web3dart
- `EthereumAddress` - from web3dart
- `Network` - Network enum
- `NetworkConfig` - Network configuration
- `PlasmaTheme` - Design system

---

## Examples

See [example/lib/main.dart](../example/lib/main.dart) for complete examples.
