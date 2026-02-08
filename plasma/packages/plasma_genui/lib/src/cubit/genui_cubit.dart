import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';

import '../models/chat_feed_item.dart';
import '../models/chat_message.dart';
import 'genui_state.dart';

class GenUiCubit extends Cubit<GenUiState> {
  final ContentGenerator _generator;
  final A2uiMessageProcessor _processor;
  late final GenUiConversation _conversation;

  StreamSubscription<A2uiMessage>? _a2uiSubscription;
  StreamSubscription<String>? _textSubscription;
  StreamSubscription<ContentGeneratorError>? _errorSubscription;

  final List<PlasmaFeedItem> _items = [];

  GenUiCubit({
    required ContentGenerator generator,
    required A2uiMessageProcessor processor,
  })  : _generator = generator,
        _processor = processor,
        super(const GenUiInitial()) {
    _initializeConversation();
    _setupListeners();
  }

  void _initializeConversation() {
    _conversation = GenUiConversation(
      a2uiMessageProcessor: _processor,
      contentGenerator: _generator,
      onSurfaceAdded: (update) {
        debugPrint(
            '🔷 GenUiCubit: onSurfaceAdded called - ${update.surfaceId}');
        if (!_hasSurface(update.surfaceId)) {
          _items.add(PlasmaFeedItem.surface(update.surfaceId));
        }
        emit(GenUiSurfaceAdded(items: List.from(_items)));
      },
      onSurfaceUpdated: (update) {
        debugPrint(
            '🔹 GenUiCubit: onSurfaceUpdated called - ${update.surfaceId}');
        if (!_hasSurface(update.surfaceId)) {
          _items.add(PlasmaFeedItem.surface(update.surfaceId));
        }
        emit(GenUiSurfaceAdded(items: List.from(_items)));
      },
      onSurfaceDeleted: (update) {
        debugPrint(
            '🔶 GenUiCubit: onSurfaceDeleted called - ${update.surfaceId}');
        _items.removeWhere(
          (item) => item.isSurface && item.surfaceId == update.surfaceId,
        );
        emit(GenUiMessageReceived(items: List.from(_items)));
      },
    );
  }

  bool _hasSurface(String surfaceId) {
    return _items.any((item) => item.isSurface && item.surfaceId == surfaceId);
  }

  void _setupListeners() {
    _a2uiSubscription = _generator.a2uiMessageStream.listen((message) {
      debugPrint(
          '🔍 GenUiCubit: Received raw A2UI message of type ${message.runtimeType}');
      if (message is SurfaceUpdate) {
        debugPrint('🔍 GenUiCubit: Raw SurfaceUpdate for ${message.surfaceId}');
      }
    });

    _textSubscription = _generator.textResponseStream.listen((text) {
      _items.add(
        PlasmaFeedItem.message(
          PlasmaMessage(text: text, isUser: false),
        ),
      );
      emit(GenUiMessageReceived(items: List.from(_items)));
    });

    _errorSubscription = _generator.errorStream.listen((error) {
      _items.add(
        PlasmaFeedItem.message(
          PlasmaMessage(
            text: 'Error: ${error.error}',
            isUser: false,
            isError: true,
          ),
        ),
      );
      emit(GenUiError(
        message: error.error.toString(),
        items: List.from(_items),
      ));
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _items.add(
      PlasmaFeedItem.message(
        PlasmaMessage(text: text, isUser: true),
      ),
    );

    emit(GenUiLoading(items: List.from(_items)));

    _conversation.sendRequest(UserUiInteractionMessage.text(text));
  }

  GenUiHost get host => _conversation.host;

  @override
  Future<void> close() {
    _a2uiSubscription?.cancel();
    _textSubscription?.cancel();
    _errorSubscription?.cancel();
    // GenUiConversation.dispose() already disposes contentGenerator and processor.
    _conversation.dispose();
    return super.close();
  }
}
