/// Plasma SDK - Modular blockchain wallet and payment SDK for Flutter
library plasma;

export 'package:plasma_bridge/plasma_bridge.dart';
// Re-export all sub-packages
export 'package:plasma_core/plasma_core.dart';
export 'package:plasma_payment/plasma_payment.dart';
export 'package:plasma_ui/plasma_ui.dart';
export 'package:plasma_wallet/plasma_wallet.dart';

export 'src/api/plasma_api.dart';
// Main SDK exports
export 'src/plasma_sdk.dart';
export 'src/widgets/plasma_widgets.dart';
