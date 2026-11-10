import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:flutter/foundation.dart';

import '../catalog/plasma_catalog.dart';
import 'content_generator.dart';

class MockContentGenerator implements ContentGenerator {
  static final String _version = A2uiProtocolVersion.v0_9.jsonValue;

  final StreamController<AgentToRendererMessage> _a2uiController =
      StreamController.broadcast();
  final StreamController<String> _textController = StreamController.broadcast();
  final StreamController<ContentGeneratorError> _errorController =
      StreamController.broadcast();
  final ValueNotifier<bool> _isProcessing = ValueNotifier(false);
  final Set<String> _createdSurfaceIds = {};
  bool _disposed = false;

  @override
  Stream<AgentToRendererMessage> get a2uiMessageStream =>
      _a2uiController.stream;

  @override
  Stream<String> get textResponseStream => _textController.stream;

  @override
  Stream<ContentGeneratorError> get errorStream => _errorController.stream;

  @override
  ValueListenable<bool> get isProcessing => _isProcessing;

  @override
  Future<void> sendRequest(String text) async {
    if (_disposed) return;
    _isProcessing.value = true;

    final String userInputRaw = text;
    final String userInput = userInputRaw.toLowerCase();

    await Future.delayed(const Duration(seconds: 1));

    try {
      if (_isPaymentIntent(userInput)) {
        final toAddress = _extractPaymentToAddress(userInputRaw);
        final amount = _extractPaymentAmount(userInputRaw);

        final summary = StringBuffer('Opening payment view');
        if (amount != null && toAddress != null) {
          summary.write(' for $amount USDT to $toAddress.');
        } else if (amount != null) {
          summary.write(' with amount $amount USDT.');
        } else if (toAddress != null) {
          summary.write(' for recipient $toAddress.');
        } else {
          summary.write('.');
        }
        _textController.add(summary.toString());

        await Future.delayed(const Duration(milliseconds: 200));

        final paymentProps = <String, Object?>{};
        if (toAddress != null) paymentProps['toAddress'] = toAddress;
        if (amount != null) paymentProps['amount'] = amount;

        _showSurface('payment_surface', 'PaymentView', paymentProps);
      } else if (_isTransactionIntent(userInput)) {
        final number = _extractTransactionCount(userInput);
        _textController.add('Showing your last $number transactions.');

        await Future.delayed(const Duration(milliseconds: 200));

        _showSurface(
            'transaction_history_surface', 'PlasmaTranscationHistory', {
          'number': number,
        });
      } else if (userInput.contains('balance') ||
          userInput.contains('how much') ||
          userInput.contains('funds') ||
          userInput.contains('wallet')) {
        _textController.add('Here\'s your wallet information:');

        await Future.delayed(const Duration(milliseconds: 200));

        _showSurface('balance_surface', 'PlasmaWalletCard', const {});
      } else {
        _textController.add(
          'I can show wallet, transaction history, or payment view. Try "What\'s my balance?", "Show me last 4 transactions", or "Send 1 USDT to 0x...".',
        );
      }
    } catch (e, stackTrace) {
      if (!_disposed) {
        _errorController.add(ContentGeneratorError(e, stackTrace));
      }
    } finally {
      if (!_disposed) {
        _isProcessing.value = false;
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _a2uiController.close();
    _textController.close();
    _errorController.close();
    _isProcessing.dispose();
  }

  /// Shows a surface whose root is a [component] with [properties].
  ///
  /// A surface shown before is updated in place, as genui did for a second
  /// beginRendering.
  void _showSurface(
    String surfaceId,
    String component,
    Map<String, Object?> properties,
  ) {
    if (_createdSurfaceIds.add(surfaceId)) {
      debugPrint('🎨 MockContentGenerator: Sending createSurface - $surfaceId');
      _a2uiController.add(CreateSurfaceMessage(
        version: _version,
        surfaceId: surfaceId,
        catalogId: plasmaCatalogId,
      ));
    }
    debugPrint(
      '🎨 MockContentGenerator: Sending updateComponents - $surfaceId',
    );
    _a2uiController.add(UpdateComponentsMessage(
      version: _version,
      surfaceId: surfaceId,
      components: [
        {'id': 'root', 'component': component, ...properties},
      ],
    ));
  }

  bool _isTransactionIntent(String input) {
    return input.contains('transaction') ||
        input.contains('transactions') ||
        input.contains('transcation') ||
        input.contains('transcations') ||
        input.contains('history') ||
        input.contains('last');
  }

  bool _isPaymentIntent(String input) {
    final hasAction = input.contains('send') ||
        input.contains('pay') ||
        input.contains('payment') ||
        input.contains('transfer');
    if (!hasAction) return false;

    return input.contains('usdt') ||
        input.contains('usd') ||
        input.contains('to ');
  }

  String? _extractPaymentAmount(String input) {
    final amountWithToken = RegExp(
      r'\b(\d+(?:\.\d+)?)\s*(?:usdt0?|usdt|usd)\b',
      caseSensitive: false,
    ).firstMatch(input);
    if (amountWithToken != null) {
      return amountWithToken.group(1);
    }

    final firstNumber = RegExp(r'\b(\d+(?:\.\d+)?)\b').firstMatch(input);
    return firstNumber?.group(1);
  }

  String? _extractPaymentToAddress(String input) {
    final hexAddress = RegExp(
      r'\b0x[a-fA-F0-9]{40}\b',
    ).firstMatch(input);
    if (hexAddress != null) {
      return hexAddress.group(0);
    }

    final quotedTarget = RegExp(
      r'''\bto\s+["“']([^"”']+)["”']''',
      caseSensitive: false,
    ).firstMatch(input);
    if (quotedTarget != null) {
      final value = quotedTarget.group(1)?.trim();
      if (value != null && value.isNotEmpty) return value;
    }

    final genericTarget = RegExp(
      r'\bto\s+([^\n,.;!?]+)',
      caseSensitive: false,
    ).firstMatch(input);
    if (genericTarget != null) {
      final value = genericTarget.group(1)?.trim();
      if (value != null && value.isNotEmpty) return value;
    }

    return null;
  }

  int _extractTransactionCount(String input) {
    final match = RegExp(r'\d+').firstMatch(input);
    if (match == null) return 10;

    final parsed = int.tryParse(match.group(0)!);
    if (parsed == null) return 10;
    if (parsed <= 0) return 10;
    if (parsed > 50) return 50;
    return parsed;
  }
}
