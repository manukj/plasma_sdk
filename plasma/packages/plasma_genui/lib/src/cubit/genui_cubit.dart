import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';

import '../models/chat_message.dart';
import '../providers/mock_content_generator.dart';
import 'genui_state.dart';

/// Cubit for managing GenUI conversation state
class GenUiCubit extends Cubit<GenUiState> {
  final MockContentGenerator _generator;
  final A2uiMessageProcessor _processor;
  late final GenUiConversation _conversation;

  StreamSubscription<String>? _textSubscription;
  StreamSubscription<ContentGeneratorError>? _errorSubscription;

  final List<PlasmaMessage> _messages = [];
  final List<String> _surfaceIds = [];

  GenUiCubit({
    required MockContentGenerator generator,
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
        _surfaceIds.add(update.surfaceId);
        emit(GenUiSurfaceAdded(
          messages: List.from(_messages),
          surfaceIds: List.from(_surfaceIds),
        ));
      },
      onSurfaceDeleted: (update) {
        _surfaceIds.remove(update.surfaceId);
        emit(GenUiMessageReceived(
          messages: List.from(_messages),
          surfaceIds: List.from(_surfaceIds),
        ));
      },
    );
  }

  void _setupListeners() {
    // Listen to text responses
    _textSubscription = _generator.textResponseStream.listen((text) {
      _messages.add(PlasmaMessage(text: text, isUser: false));
      emit(GenUiMessageReceived(
        messages: List.from(_messages),
        surfaceIds: List.from(_surfaceIds),
      ));
    });

    // Listen to errors
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

  /// Send a user message
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(PlasmaMessage(text: text, isUser: true));

    // Emit loading state
    emit(GenUiLoading(
      messages: List.from(_messages),
      surfaceIds: List.from(_surfaceIds),
    ));

    // Send to conversation
    _conversation.sendRequest(UserUiInteractionMessage.text(text));
  }

  /// Get the conversation host for rendering surfaces
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
