import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';

/// Mock AI provider for testing GenUI without real AI backend
/// Uses simple keyword matching to trigger widget rendering
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

    // Extract text from message
    String userInput = '';
    if (message is UserUiInteractionMessage) {
      userInput = message.text.toLowerCase();
    }

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 20));

    try {
      // Simple keyword matching for balance query
      if (userInput.contains('balance') ||
          userInput.contains('how much') ||
          userInput.contains('funds') ||
          userInput.contains('wallet')) {
        // Send text response
        _textController.add('Here\'s your wallet information:');

        // Send A2UI SurfaceUpdate message
        _a2uiController.add(SurfaceUpdate(
          surfaceId: 'balance_surface',
          components: [
            Component(
              id: 'wallet_card',
              componentProperties: {
                'type': 'PlasmaWalletCard',
                'properties': {},
              },
            ),
          ],
        ));
      } else {
        // Default response for unrecognized queries
        _textController.add(
          'I can help you check your balance. Try asking "What\'s my balance?"',
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
    if (_disposed) return; // Prevent double disposal
    _disposed = true;
    _a2uiController.close();
    _textController.close();
    _errorController.close();
    _isProcessing.dispose();
  }
}
