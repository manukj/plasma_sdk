# Plasma SDK Flutter Infra

## Goal

This document explains the internal multi-module architecture of the Plasma Flutter SDK and how data flows between packages.

---

## Repository Structure (High Level)

```text
plasma/
|_ lib/
|  |_ plasma.dart                    # Root export surface
|  |_ src/plasma_sdk.dart            # SDK facade/singleton (Plasma.instance)
|  |_ src/widgets/                   # SDK-level ready widgets
|
|_ packages/
|  |_ plasma_core/                   # Network and shared core config
|  |_ plasma_bridge/                 # JS bridge + headless webview signing
|  |_ plasma_wallet/                 # Wallet, balances, token tx history
|  |_ plasma_payment/                # Payment orchestration/business flow
|  |_ plasma_ui/                     # Shared UI primitives/theme
|  |_ plasma_genui/                  # Conversational/intent-driven UI layer
|
|_ assets/
|  |_ js_project/index.js            # Bridge JS source logic
|  |_ www/bundle.js                  # Bundled JS consumed by bridge webview
|
|_ example/                          # Integration demo app
```

---

## Package Responsibilities

### `lib/` (Root SDK package)
- Exposes a single integration facade: `Plasma.instance`.
- Wires all internal packages in `Plasma.init(...)`.
- Re-exports SDK APIs and selected widgets.

### `packages/plasma_core`
- Owns network definitions (`testnet`/`mainnet`).
- Provides `NetworkConfig` values:
  - RPC URL
  - Chain ID
  - USDT0 contract
  - Relayer URL
  - Etherscan API base URL

### `packages/plasma_bridge`
- Hosts headless `InAppWebView` runtime.
- Injects `assets/www/bundle.js`.
- Exposes bridge calls (`signGaslessTransfer`, `signGaslessUSDT`).
- Normalizes keys and bridges Dart <-> JS async execution.

### `packages/plasma_wallet`
- Manages private key and address lifecycle (`flutter_secure_storage`).
- Provides balances:
  - `getGasTokenBalance()` for XPL
  - `getStableTokenBalance()` for USDT0 (ERC-20 `balanceOf`)
- Provides token transaction history through data/repository/model layers.

### `packages/plasma_payment`
- Orchestrates transfer flow (`sendUSDT`).
- Pulls wallet credentials/address from `plasma_wallet`.
- Uses `plasma_bridge` for signing/submission response.
- Uses `NetworkConfig` for token contract + RPC context.

### `packages/plasma_ui`
- Reusable SDK UI primitives and theme tokens.
- Example: `PlasmaButton`, `PlasmaLoadingWidget`, `PlasmaTheme`.

### `packages/plasma_genui`
- Intent-driven conversational UI shell.
- Uses catalog-driven surfaces (`PlasmaWalletCard`, `PlasmaTranscationHistory`, `PaymentView`).
- Supports generator strategy via enum:
  - `ContentGeneratorType.mock`
  - `ContentGeneratorType.firebase`

---

## Dependency Map

```text
App
|_ plasma (root facade)
   |_ plasma_core
   |_ plasma_bridge
   |_ plasma_wallet
   |_ plasma_payment
   |_ plasma_ui
   |_ (optional) plasma_genui
```

```text
plasma_payment
|_ depends on plasma_wallet
|_ depends on plasma_bridge
|_ depends on plasma_core (NetworkConfig)
```

```text
plasma_genui
|_ depends on genui + generator implementations
|_ depends on plasma widgets/catalog items
|_ consumes state and widgets from root SDK package
```

---

## Runtime Flow Charts

### 1) SDK Initialization Flow

```text
App startup
|_ Plasma.instance.init(network, envFile, etherscanApiKey?)
   |_ NetworkConfig.getConfig(network)
   |_ EnvConfigResolver.resolveEtherscanApiKey(...)
   |_ BridgeModule + BridgeCubit
   |  |_ BridgeController.initialize()
   |     |_ load assets/www/bundle.js
   |_ WalletModule + WalletCubit
   |  |_ load wallet from secure storage
   |_ PaymentService + PaymentCubit
   |_ SDK marked initialized
```

### 2) Payment Flow (`sendUSDT`)

```text
UI (PaymentView) / caller
|_ Plasma.instance.sendUSDT(to, amount)
   |_ PaymentCubit.sendUSDT(...)
      |_ PaymentService.sendUSDT(...)
         |_ WalletModule.credentials + WalletModule.address
         |_ NetworkConfig.usdt0Address + NetworkConfig.rpcUrl
         |_ BridgeModule.signGaslessUSDT(...)
            |_ BridgeController.callAsyncJavaScript(...)
               |_ window.bridge.signGaslessTransfer(...) in bundle.js
               |_ JS returns JSON response (expects txHash/hash)
         |_ extract txHash
   |_ return txHash to caller
```

### 3) Token Transaction History Flow

```text
UI (PlasmaTranscationHistory)
|_ Plasma.instance.getTokenTransactions(number)
   |_ WalletModule.getTokenTransactions(number)
      |_ TokenTransactionsRepository.getAddressTransactions(...)
         |_ TokenTransactionsRemoteDataSource.getAddressTransactions(...)
            |_ GET etherscan v2 api (module=account, action=tokentx)
            |_ parse response -> models
   |_ return PlasmaTokenTransactionsResponse
```

### 4) GenUI Flow

```text
User taps PlasmaGenUi trigger
|_ create catalog + choose generator type (mock/firebase)
|_ create GenUiCubit
|_ sendMessage(userText)
   |_ GenUiConversation -> ContentGenerator
   |_ textResponseStream => PlasmaFeedItem.message
   |_ SurfaceUpdate events => PlasmaFeedItem.surface
|_ PlasmaGenUiBottomSheet renders feed items in arrival order
```

---

## Clean Architecture Boundaries Used

Inside wallet transaction history:

```text
UI/SDK layer
|_ service/module layer (WalletModule)
   |_ repository interface (TokenTransactionsRepository)
      |_ repository implementation
         |_ remote data source (HTTP)
            |_ model mapping (API JSON -> strongly typed models/entities)
```

This keeps API details isolated from widgets and top-level SDK callers.

