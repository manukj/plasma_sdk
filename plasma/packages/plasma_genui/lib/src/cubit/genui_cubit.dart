import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';

import '../models/chat_message.dart';
import 'genui_state.dart';

class GenUiCubit extends Cubit<GenUiState> {
  final ContentGenerator _generator;
  final A2uiMessageProcessor _processor;
  late final GenUiConversation _conversation;

  StreamSubscription<String>? _textSubscription;
  StreamSubscription<ContentGeneratorError>? _errorSubscription;

  final List<PlasmaMessage> _messages = [];
  final List<String> _surfaceIds = [];

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
        if (!_surfaceIds.contains(update.surfaceId)) {
          _surfaceIds.add(update.surfaceId);
          debugPrint('🔷 GenUiCubit: Surface IDs now: $_surfaceIds');
          emit(GenUiSurfaceAdded(
            messages: List.from(_messages),
            surfaceIds: List.from(_surfaceIds),
          ));
        } else {
          debugPrint(
              '🔷 GenUiCubit: Surface ID ${update.surfaceId} already exists, ignoring add');
        }
      },
      onSurfaceUpdated: (update) {
        debugPrint(
            '🔹 GenUiCubit: onSurfaceUpdated called - ${update.surfaceId}');
        if (!_surfaceIds.contains(update.surfaceId)) {
          _surfaceIds.add(update.surfaceId);
          debugPrint(
              '🔹 GenUiCubit: Added missing surface via update: $_surfaceIds');
          emit(GenUiSurfaceAdded(
            messages: List.from(_messages),
            surfaceIds: List.from(_surfaceIds),
          ));
        }
      },
      onSurfaceDeleted: (update) {
        debugPrint(
            '🔶 GenUiCubit: onSurfaceDeleted called - ${update.surfaceId}');
        _surfaceIds.remove(update.surfaceId);
        emit(GenUiMessageReceived(
          messages: List.from(_messages),
          surfaceIds: List.from(_surfaceIds),
        ));
      },
    );
  }

  void _setupListeners() {
    _generator.a2uiMessageStream.listen((message) {
      debugPrint(
          '🔍 GenUiCubit: Received raw A2UI message of type ${message.runtimeType}');
      if (message is SurfaceUpdate) {
        debugPrint('🔍 GenUiCubit: Raw SurfaceUpdate for ${message.surfaceId}');
      }
    });

    _textSubscription = _generator.textResponseStream.listen((text) {
      _messages.add(PlasmaMessage(text: text, isUser: false));
      emit(GenUiMessageReceived(
        messages: List.from(_messages),
        surfaceIds: List.from(_surfaceIds),
      ));
    });

    _errorSubscription = _generator.errorStream.listen((error) {
      _messages.add(PlasmaMessage(
        text: 'Error: ${error.error}',
        isUser: false,
        isError: true,
      ));
      emit(GenUiError(
        message: error.error.toString(),
        messages: List.from(_messages),
        surfaceIds: List.from(_surfaceIds),
      ));
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messages.add(PlasmaMessage(text: text, isUser: true));

    emit(GenUiLoading(
      messages: List.from(_messages),
      surfaceIds: List.from(_surfaceIds),
    ));

    _conversation.sendRequest(UserUiInteractionMessage.text(text));
  }

  GenUiHost get host => _conversation.host;

  @override
  Future<void> close() {
    _textSubscription?.cancel();
    _errorSubscription?.cancel();
    _generator.dispose();
    _conversation.dispose();
    return super.close();
  }
}
