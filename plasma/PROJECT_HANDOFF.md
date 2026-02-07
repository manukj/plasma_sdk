# Plasma SDK - Development Project Handoff

## 🚀 Project Overview
**Plasma SDK** is a Flutter package designed for blockchain wallet management and offline crypto operations. Its unique feature is a **Headless JavaScript Bridge** that allows complex crypto logic (via `viem`) to run inside a Flutter app without requiring a server or external CDN.

---

## 🏗️ Architecture

### 1. `Plasma.dart` (The Coordinator)
- **Pattern**: Singleton (`Plasma.instance`).
- **Initialization**: `init(isTestnet: true)`.
- **Modules**: Manages the `WalletModule` and `BridgeModule`.

### 2. `WalletModule` (Identity & Native)
- **Package**: `web3dart` + `flutter_secure_storage`.
- **Purpose**: Key generation (BIP39/Hex), secure key persistence (iOS Keychain / Android Keystore), and native balance (XPL) checking.
- **Methods**: `create()`, `load()`, `clear()`, `getNativeBalance()`.

### 3. `BridgeModule` (The "Offline Brain")
- **Technology**: `HeadlessInAppWebView` + `viem` (JavaScript).
- **JS project**: Managed in `assets/js_project/`.
- **Bundler**: Webpack compiles `viem` and polyfills (Buffer) into a 146KB `bundle.js`.
- **Injection**: Loaded from assets via `rootBundle` and injected via `evaluateJavascript` in `onLoadStop` for maximum reliability.
- **Methods**: `init()`, `ping()`, `sendUSDT()`.

---

## 🛠️ Development Environment

### JS Bridge Maintenance
If you need to update the JavaScript logic (e.g., adding Gasless support):
1. Go to `assets/js_project/`.
2. Edit `index.js`.
3. Run: `npx webpack --config webpack.config.cjs`.
4. The output will automatically go to `assets/www/bundle.js`.

### Assets Disclaimer
- **Pathing**: Assets inside this package are accessed via `packages/plasma/assets/www/...` in Dart.
- **WebView**: Android requires `initialData` with inline HTML or `about:blank` + `evaluateJavascript` to bypass strict URL scheme/cleartext restrictions.

---

## ✅ Current State
- **Wallet**: Generates securely, saves to device, survives app restarts.
- **Balances**: Native XPL balance checking is working via `web3dart` RPC.
- **Bridge**: Successfully loads a bundled version of `viem` (Minified, 146KB).
- **Transactions**: `sendUSDT` method is implemented in both JS and Dart, ready for testing on Plasma Testnet (Chain ID 9746).
- **UI**: The `example/` app features a full testing suite for every SDK method.

---

## ⏭️ Next Steps for the Next API/Agent
1. **Gasless Transactions (ERC-4337)**: Use the existing `viem` bundle to implement User Operations and contact a Bundler.
2. **Tx Polling**: Implement a Dart helper to poll for the transaction hash status after sending.
3. **Recovery**: Implement Seed Phrase (Mnemonic) backup for the wallets.

---

## 🛡️ "War Room" Log (Fixed Issues)
- **BigInt Compatibility**: Avoid `0n` literals in JS; use `BigInt(0)` to support older Android system WebViews.
- **Injection Method**: `initialData` interpolation of large strings (>100KB) can lead to Syntax Errors. Always use `controller.evaluateJavascript(source: bundleJs)` inside `onLoadStop`.
- **BouncyCastle Conflicts**: Avoid adding the Particle Auth SDK directly if using `web3dart` on Android, as they conflict on cryptographic provider classes.
