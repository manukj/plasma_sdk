# Plasma SDK

## Overview

**Plasma SDK** is a Flutter SDK that helps apps **embed wallets, balances, and payments on Plasma** without requiring developers to build blockchain infrastructure or UI flows from scratch.

It provides:

* Secure wallet lifecycle management
* Read access to gas and stable token balances
* Token transaction history
* A ready-made USDT payment flow
* State-driven access to wallet and payment data
* Optional **GenUI** surfaces for intent-based user interactions

The SDK is exposed as a singleton:

```dart
Plasma.instance
```

---

## What Problem Plasma SDK Solves

Building on-chain payments usually requires:

* Managing private keys and wallets
* Handling RPCs, balances, gas, and errors
* Designing complex UI flows for payments
* Keeping state consistent across the app

**Plasma SDK abstracts all of this** into:

* A small, predictable API
* Production-ready UI components
* A state-driven architecture (Cubits)
* Optional AI-powered interaction surfaces (GenUI)

So your app can focus on **user experience**, not blockchain plumbing.

---

## Initialization

Initialize Plasma once during app startup.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Plasma.instance.init(
    network: Network.testnet,
    envFile: '.env', // optional
  );

  runApp(const MyApp());
}
```

### API Key Resolution

The SDK resolves the Etherscan API key in this order:

1. `etherscanApiKey` passed to `init`
2. `ETHERSCANAPI` from the `.env` file

If no key is found, initialization fails with a `StateError`.

---

## Core Capabilities

### Wallet Lifecycle

Manage user wallets without exposing low-level cryptography.

* Create a new wallet
* Load an existing wallet (test/dev)
* Delete wallet data
* Observe wallet state via Cubits

---

### Balances

Read current balances at any time:

* Native gas token (XPL)
* Stable token (USDT0)

Balances are automatically tied to the active wallet and network.

---

### Payments & Transactions

* Send USDT to another address
* Track transaction history
* Access transaction hashes and states
* Integrate payments into your own UI or use built-in views

---

## Public API (`Plasma.instance`)

### Runtime State

| Property        | Description                    |
| --------------- | ------------------------------ |
| `network`       | Active Plasma network          |
| `config`        | Resolved network configuration |
| `isInitialized` | SDK initialization status      |
| `hasWallet`     | Whether a wallet exists        |
| `address`       | Current wallet address         |
| `wallet`        | Wallet state and actions       |
| `payment`       | Payment state and actions      |
| `bridge`        | Network bridge state           |

---

### Core Methods

| Method                    | Purpose                                      |
| ------------------------- | -------------------------------------------- |
| `init()`                  | Initializes SDK and network                  |
| `createWallet()`          | Creates a new wallet                         |
| `deleteWallet()`          | Clears wallet data                           |
| `loadTestWallet()`        | Loads a wallet from a private key (dev only) |
| `getGasTokenBalance()`    | Reads XPL balance                            |
| `getStableTokenBalance()` | Reads USDT balance                           |
| `getTokenTransactions()`  | Reads transaction history                    |
| `sendUSDT()`              | Sends a USDT payment                         |

---

## Minimal Integration Flow

1. Initialize the SDK
2. Create or load a wallet
3. Read balances
4. Send a payment
5. Display transaction history

This entire flow can be implemented **without writing custom blockchain logic**.

---

## GenUI: Purpose & Philosophy

### What GenUI Is

**GenUI** is an optional layer that allows users to interact with Plasma features using **intent-driven UI surfaces** instead of rigid flows.

Rather than hard-coding:

* “Go to wallet screen”
* “Open payment page”
* “Tap transaction history”

GenUI enables:

* Context-aware UI
* Dynamic surfaces generated from user intent
* Conversational entry points into wallet and payment actions

This makes blockchain interactions feel **natural, discoverable, and adaptive**.

---

### What GenUI Is *Not*

* It is **not** a prompt-command system
* It does **not** expose raw blockchain actions
* It does **not** replace your app’s navigation

GenUI is a **UI orchestration layer**, not a scripting interface.

---

### What GenUI Does

GenUI:

* Interprets user intent
* Decides *which UI surface* to present
* Renders structured, production-safe widgets
* Keeps wallet and payment state in sync

Examples of generated surfaces:

* Wallet overview cards
* Transaction history views
* Payment confirmation flows

---

## Using GenUI

```dart
import 'package:plasma_genui/plasma_genui.dart';

const PlasmaGenUi();
```

* Ships with a default mock content generator
* Can be injected with a custom content generator
* Renders as a bottom-sheet chat-style interaction

GenUI integrates seamlessly with existing Plasma state and UI components.

---

## Example Demo Screens

### Plasma SDK Overview

* SDK initialization example
* Capability overview

`[Add screenshot: Plasma SDK Overview]`

---

### Plasma UI Overview

* Create Wallet
* Load Test Wallet
* Wallet Card
* Transaction History
* Send Payment

(All actions disabled until a wallet exists)

`[Add screenshot: Plasma UI Overview]`

---

### Plasma GenUI

* Entry point for intent-based interactions
* Dynamic surfaces rendered from user intent

`[Add screenshot: Plasma GenUI]`
`[Add GIF: GenUI interaction flow]`

---

## Built-in UI Components

### `PlasmaButton`

Primary SDK CTA component
`[Screenshot]`

---

### `PlasmaLoadingWidget`

Standard loading and progress UI
`[Screenshot]`

---

### `PlasmaWalletCard`

Wallet summary (address + balances)
`[Screenshot]`

---

### `PlasmaTransactionHistory`

Transaction list widget
`[Screenshot]`

---

### `PaymentView`

Complete USDT payment UI
`[Screenshot]`

---

## Final Takeaway

Plasma SDK gives you:

* Wallets without complexity
* Payments without boilerplate
* UI without guesswork
* GenUI without forcing users through rigid flows

It’s designed to make **on-chain payments feel like native app features**.
