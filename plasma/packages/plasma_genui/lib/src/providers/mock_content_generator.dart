import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';

import '../catalog/plasma_catalog.dart';

class MockContentGenerator implements ContentGenerator {
  final StreamController<A2uiMessage> _a2uiController =
      StreamController.broadcast();
  final StreamController<String> _textController = StreamController.broadcast();
  final StreamController<ContentGeneratorError> _errorController =
      StreamController.broadcast();
  final ValueNotifier<bool> _isProcessing = ValueNotifier(false);
  bool _disposed = false;

  @override
  Stream<A2uiMessage> get a2uiMessageStream => _a2uiController.stream;

  @override
  Stream<String> get textResponseStream => _textController.stream;

  @override
  Stream<ContentGeneratorError> get errorStream => _errorController.stream;

  @override
  ValueListenable<bool> get isProcessing => _isProcessing;

  @override
  Future<void> sendRequest(
    ChatMessage message, {
    Iterable<ChatMessage>? history,
    A2UiClientCapabilities? clientCapabilities,
  }) async {
    if (_disposed) return;
    _isProcessing.value = true;

    String userInput = '';
    String userInputRaw = '';
    if (message is UserUiInteractionMessage) {
      userInputRaw = message.text;
      userInput = userInputRaw.toLowerCase();
    }

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

        const surfaceId = 'payment_surface';
        const rootComponentId = 'payment_view';
        final paymentProps = <String, Object?>{};
        if (toAddress != null) paymentProps['toAddress'] = toAddress;
        if (amount != null) paymentProps['amount'] = amount;

        final surfaceUpdate = SurfaceUpdate(
          surfaceId: surfaceId,
          components: [
            Component(
              id: rootComponentId,
              componentProperties: {
                'PaymentView': paymentProps,
              },
            ),
          ],
        );

        debugPrint(
          '🎨 MockContentGenerator: Sending SurfaceUpdate - ${surfaceUpdate.surfaceId}',
        );
        _a2uiController.add(surfaceUpdate);

        final beginRendering = const BeginRendering(
          surfaceId: surfaceId,
          root: rootComponentId,
          catalogId: plasmaCatalogId,
        );
        debugPrint(
          '🎨 MockContentGenerator: Sending BeginRendering - ${beginRendering.surfaceId}',
        );
        _a2uiController.add(beginRendering);
      } else if (_isTransactionIntent(userInput)) {
        final number = _extractTransactionCount(userInput);
        _textController.add('Showing your last $number transactions.');

        await Future.delayed(const Duration(milliseconds: 200));

        const surfaceId = 'transaction_history_surface';
        const rootComponentId = 'transaction_history';
        final surfaceUpdate = SurfaceUpdate(
          surfaceId: surfaceId,
          components: [
            Component(
              id: rootComponentId,
              componentProperties: {
                'PlasmaTranscationHistory': <String, Object?>{
                  'number': number,
                },
              },
            ),
          ],
        );

        debugPrint(
          '🎨 MockContentGenerator: Sending SurfaceUpdate - ${surfaceUpdate.surfaceId}',
        );
        _a2uiController.add(surfaceUpdate);

        final beginRendering = const BeginRendering(
          surfaceId: surfaceId,
          root: rootComponentId,
          catalogId: plasmaCatalogId,
        );
        debugPrint(
          '🎨 MockContentGenerator: Sending BeginRendering - ${beginRendering.surfaceId}',
        );
        _a2uiController.add(beginRendering);
      } else if (userInput.contains('balance') ||
          userInput.contains('how much') ||
          userInput.contains('funds') ||
          userInput.contains('wallet')) {
        _textController.add('Here\'s your wallet information:');

        await Future.delayed(const Duration(milliseconds: 200));

        const surfaceId = 'balance_surface';
        const rootComponentId = 'wallet_card';
        final surfaceUpdate = SurfaceUpdate(
          surfaceId: surfaceId,
          components: [
            Component(
              id: rootComponentId,
              componentProperties: const {
                'PlasmaWalletCard': <String, Object?>{},
              },
            ),
          ],
        );

        debugPrint(
            '🎨 MockContentGenerator: Sending SurfaceUpdate - ${surfaceUpdate.surfaceId}');
        _a2uiController.add(surfaceUpdate);

        final beginRendering = const BeginRendering(
          surfaceId: surfaceId,
          root: rootComponentId,
          catalogId: plasmaCatalogId,
        );
        debugPrint(
          '🎨 MockContentGenerator: Sending BeginRendering - ${beginRendering.surfaceId}',
        );
        _a2uiController.add(beginRendering);
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
