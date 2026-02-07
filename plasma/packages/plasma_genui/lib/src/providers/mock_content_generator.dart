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
    if (message is UserUiInteractionMessage) {
      userInput = message.text.toLowerCase();
    }

    await Future.delayed(const Duration(seconds: 1));

    try {
      if (userInput.contains('balance') ||
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
    if (_disposed) return; 
    _disposed = true;
    _a2uiController.close();
    _textController.close();
    _errorController.close();
    _isProcessing.dispose();
  }
}
