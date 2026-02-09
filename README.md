# Plasma Mobile SDK



  <img
    src="https://github.com/user-attachments/assets/5e620e42-4f8b-4b20-b611-5dc07189d4f7"
    alt="Demo"
    width="280"
  />
  <br/>
  <sub>Plasma SDK – wallet & payment flow demo</sub>



---

## What Is Plasma Mobile SDK

The **Plasma Mobile SDK** is a mobile integration layer, provided as a Flutter package, designed to simplify bringing Plasma blockchain capabilities into mobile apps.

Its primary objective is to increase stablecoin adoption by enabling merchants to integrate Plasma as their **USDT payment infrastructure**.

The SDK entry point is:

```dart
Plasma.instance
```

---

## Core Value

Plasma Mobile SDK gives teams a single integration surface for:

- wallet lifecycle
- account state
- stablecoin payment execution
- transaction retrieval
- reusable UI surfaces
- AI-powered dynamic UI via GenUI

This reduces integration effort and makes production adoption faster.

---

## Key Functionalities

### 1. Core Operations

- create wallet
- load existing/test wallet
- read gas and stable token balances
- send USDT payments
- fetch transaction history

### 2. Public API + Ready UI

The SDK provides both:

- public APIs for programmatic control
- prebuilt widgets for immediate integration

Examples:

- `PlasmaWalletCard`
- `PlasmaTranscationHistory`
- `PaymentView`

### 3. Internal Runtime Architecture

The SDK internally bundles Plasma network configuration and uses a headless browser runtime for bridge-driven blockchain operations.

At runtime:

- Flutter app calls SDK APIs
- SDK uses a JS bridge (`plasma_bridge`)
- headless WebView runs bundled JS (`assets/www/bundle.js`)
- bundled JS connects to Plasma RPC and signs/submits flow-specific operations

---

## Public APIs (`Plasma.instance`)

| Method | Purpose |
| --- | --- |
| `init()` | Initialize SDK/network |
| `createWallet()` | Create new wallet |
| `deleteWallet()` | Clear wallet |
| `getGasTokenBalance()` | Get XPL balance |
| `getStableTokenBalance()` | Get USDT0 balance |
| `getTokenTransactions(number)` | Get transaction history |
| `sendUSDT(to, amount)` | Send stablecoin payment |

---

## GenUI (Generative UI)

`Plasma GenUI` is a context-aware conversational layer that dynamically composes SDK surfaces based on user intent.

Instead of merchants building static flows for every action, they can expose a chatbot-like entry that drives the same trusted SDK widgets.

### What It Enables

- intent-based actions through natural input
- pre-filled payment surfaces
- dynamic balance and transaction views
- faster UX iteration without hardcoded route trees

### Example User Intents

- “send 0.23 USDT to 0x...”
- “show my wallet balance”
- “show my last two transactions”

In each case, GenUI uses existing SDK components to render the correct surface in context.

---

## Why This Matters For Plasma

Plasma is purpose-built for stablecoin payments.  
Plasma Mobile SDK makes that usable in real merchant apps by combining:

- payment-ready APIs
- reusable mobile UI components
- modular internals (`core`, `wallet`, `payment`, `bridge`, `ui`, `genui`)
- GenUI for intent-driven, context-aware payment UX

This creates a faster path from blockchain infrastructure to real user-facing payment products.

---

## UI Components

The SDK ships reusable UI building blocks for payment experiences:

- `PlasmaButton`
- `PlasmaLoadingWidget`
- `PlasmaWalletCard`
- `PlasmaTranscationHistory`
- `PaymentView`

`[Add screenshot: PlasmaButton]`
`[Add screenshot: PlasmaLoadingWidget]`
`[Add screenshot: PlasmaWalletCard]`
`[Add screenshot: PlasmaTranscationHistory]`
`[Add screenshot: PaymentView]`

---
