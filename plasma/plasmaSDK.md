# Plasma SDK

## What Is Plasma SDK
Plasma SDK is a Flutter SDK for:
- Wallet lifecycle management
- Gas token and stable token balance reads
- Token transaction history reads
- USDT transfer flow
- Wallet and payment state access via Cubits

It is exposed as a singleton:

```dart
Plasma.instance
```

## How To Initialize
Use this once at app startup:

```dart
import 'package:flutter/widgets.dart';
import 'package:plasma/plasma.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Plasma.instance.init(
    network: Network.testnet,
    envFile: '.env', // optional, default is '.env'
    // etherscanApiKey: 'YOUR_KEY', // optional override
  );

  runApp(const MyApp());
}
```

### API key note
`Plasma.instance.init()` resolves Etherscan key in this order:
1. `etherscanApiKey` parameter (if provided)
2. `ETHERSCANAPI` from the `.env` file set by `envFile`

If no key is found, initialization throws a `StateError`.

## Features Provided

### Wallet
- `createWallet()`
- `deleteWallet()`
- `loadTestWallet(String privateKey)`

### Balances
- `getStableTokenBalance()`
- `getGasTokenBalance()`

### Transactions & Payments
- `getTokenTransactions([int number = 10])`
- `sendUSDT({required String to, required String amount})`

### Runtime State
- `network`
- `config`
- `hasWallet`
- `address`

## Public API Surface (`Plasma.instance`)

### Getters
| API | Type | Description |
|---|---|---|
| `network` | `Network` | Active network enum |
| `config` | `NetworkConfig` | Resolved network configuration |
| `isInitialized` | `bool` | SDK initialized state |
| `hasWallet` | `bool` | Whether a wallet exists/loaded |
| `address` | `String?` | Current wallet address |
| `bridge` | `BridgeCubit` | Bridge state/actions |
| `wallet` | `WalletCubit` | Wallet state/actions |
| `payment` | `PaymentCubit` | Payment state/actions |

### Methods
| API | Return | Description |
|---|---|---|
| `init({Network network = Network.testnet, String envFile = '.env', String? etherscanApiKey})` | `Future<void>` | Initializes SDK modules and bridge |
| `createWallet()` | `Future<void>` | Creates a new wallet |
| `deleteWallet()` | `Future<void>` | Clears wallet data |
| `loadTestWallet(String privateKey)` | `Future<String>` | Loads wallet from a private key (test utility) |
| `getGasTokenBalance()` | `Future<String>` | Returns native gas token balance (XPL) |
| `getStableTokenBalance()` | `Future<String>` | Returns stable token balance (USDT0) |
| `getTokenTransactions([int number = 10])` | `Future<PlasmaTokenTransactionsResponse>` | Returns token transaction list for active wallet |
| `sendUSDT({required String to, required String amount})` | `Future<String>` | Sends USDT and returns transaction hash |

## Minimal Integration Flow
1. `await Plasma.instance.init(...)`
2. Create/load wallet (`createWallet` or `loadTestWallet`)
3. Read balances (`getStableTokenBalance`, `getGasTokenBalance`)
4. Send payment (`sendUSDT`)
5. Read history (`getTokenTransactions`)

## Example Demo Screens

### 1) Plasma SDK Overview
- Shows SDK initialization snippet
- Shows grouped SDK capabilities

Screenshot:
`[Add screenshot: Plasma SDK Overview here]`

### 2) Plasma UI Overview
- `Create Wallet` (opens create wallet bottom sheet)
- `Load Test Wallet` (loads a test private key)
- `View Plasma Card` (disabled until wallet exists, opens bottom sheet)
- `View Transcation History` (disabled until wallet exists, opens bottom sheet)
- `Send Payment` (disabled until wallet exists, opens bottom sheet)

Screenshot:
`[Add screenshot: Plasma UI Overview here]`

### 3) Plasma GenUI
- Dedicated screen for `PlasmaGenUi` trigger and dynamic AI surfaces

Screenshot:
`[Add screenshot: Plasma GenUI here]`

## UI comments from SDK

### `PlasmaButton`
- Primary CTA button component.
Screenshot:
`[Add screenshot: PlasmaButton here]`

### `PlasmaLoadingWidget`
- Standard SDK loading/progress UI.
Screenshot:
`[Add screenshot: PlasmaLoadingWidget here]`

### `showCreateWalletSheet(context)`
- Ready wallet creation bottom sheet flow.
Screenshot:
`[Add screenshot: Create Wallet Sheet here]`

### `PlasmaWalletCard`
- Wallet summary card (balances + address).
Screenshot:
`[Add screenshot: PlasmaWalletCard here]`

### `PlasmaTranscationHistory(number: ...)`
- Transaction history list widget.
Screenshot:
`[Add screenshot: PlasmaTranscationHistory here]`

### `PaymentView(...)`
- Send payment UI widget.
Screenshot:
`[Add screenshot: PaymentView here]`
