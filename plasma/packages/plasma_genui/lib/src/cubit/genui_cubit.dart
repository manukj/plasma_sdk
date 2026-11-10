import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/chat_feed_item.dart';
import '../models/chat_message.dart';
import '../providers/content_generator.dart';
import 'genui_state.dart';

class GenUiCubit extends Cubit<GenUiState> {
  final ContentGenerator _generator;
  final MessageProcessor<ComponentImplementation> _processor;

  StreamSubscription<AgentToRendererMessage>? _a2uiSubscription;
  StreamSubscription<String>? _textSubscription;
  StreamSubscription<ContentGeneratorError>? _errorSubscription;
  final List<Subscription> _surfaceSubscriptions = [];

  final List<PlasmaFeedItem> _items = [];

  GenUiCubit({
    required ContentGenerator generator,
    required MessageProcessor<ComponentImplementation> processor,
  })  : _generator = generator,
        _processor = processor,
        super(const GenUiInitial()) {
    _setupListeners();
  }

  bool _hasSurface(String surfaceId) {
    return _items.any((item) => item.isSurface && item.surfaceId == surfaceId);
  }

  void _setupListeners() {
    _surfaceSubscriptions.addAll([
      _processor.model.onSurfaceCreated.subscribe((surface) {
        debugPrint('🔷 GenUiCubit: onSurfaceCreated called - ${surface.id}');
        if (!_hasSurface(surface.id)) {
          _items.add(PlasmaFeedItem.surface(surface.id));
        }
        emit(GenUiSurfaceAdded(items: List.from(_items)));
      }),
      _processor.model.onSurfaceDeleted.subscribe((surfaceId) {
        debugPrint('🔶 GenUiCubit: onSurfaceDeleted called - $surfaceId');
        _items.removeWhere(
          (item) => item.isSurface && item.surfaceId == surfaceId,
        );
        emit(GenUiMessageReceived(items: List.from(_items)));
      }),
      _processor.model.onError.subscribe((error) {
        debugPrint(
          '🔍 GenUiCubit: Renderer error ${error.code}: ${error.message}',
        );
      }),
    ]);

    _a2uiSubscription = _generator.a2uiMessageStream.listen((message) {
      debugPrint(
          '🔍 GenUiCubit: Received A2UI message of type ${message.runtimeType}');
      _processor.processMessages(AgentToRendererMessagePayload.of(message));
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

    _generator.sendRequest(text);
  }

  /// The processor that holds the surfaces of the feed.
  MessageProcessor<ComponentImplementation> get processor => _processor;

  @override
  Future<void> close() {
    _a2uiSubscription?.cancel();
    _textSubscription?.cancel();
    _errorSubscription?.cancel();
    for (final subscription in _surfaceSubscriptions) {
      subscription.unsubscribe();
    }
    _generator.dispose();
    _processor.dispose();
    return super.close();
  }
}
