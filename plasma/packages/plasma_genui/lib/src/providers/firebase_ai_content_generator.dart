import 'dart:async';

import 'package:a2ui_agent/a2ui_agent.dart';
import 'package:a2ui_core/a2ui_core.dart';
import 'package:firebase_ai/firebase_ai.dart'
    show ChatSession, Content, FirebaseAI, StartChatExtension;
import 'package:flutter/foundation.dart';

import 'content_generator.dart';

/// A [ContentGenerator] that asks Gemini through Firebase AI for the reply,
/// and reads the A2UI messages out of it with `a2ui_agent`.
class FirebaseAiContentGenerator implements ContentGenerator {
  FirebaseAiContentGenerator({
    required CatalogApi catalog,
    this.systemInstruction,
  }) : _agent = A2uiGenerator(
          catalogs: [CatalogConfig(catalog)],
          inferenceFormatFactory: const DirectJsonFormatFactory(
            // What the surfaceUpdate, beginRendering and deleteSurface tools
            // of genui_firebase_ai let the model do.
            allowedMessages: [
              'createSurface',
              'updateComponents',
              'deleteSurface',
            ],
            // Emit whole components, as the tool calls did.
            bufferIncompleteComponents: true,
          ),
        ).createProcessor(
          A2uiRendererCapabilities.forCatalogIds(
            [catalog.id],
            version: A2uiProtocolVersion.v0_9,
          ),
        );

  /// The app's instructions, put before the A2UI format rules and catalog.
  final String? systemInstruction;

  final A2uiRequestProcessor _agent;

  /// The surfaces the replies created so far, so that a later reply can
  /// update or delete them.
  late final RendererState _state = _agent.createState();

  ChatSession? _chat;

  final _a2uiMessageController =
      StreamController<AgentToRendererMessage>.broadcast();
  final _textResponseController = StreamController<String>.broadcast();
  final _errorController = StreamController<ContentGeneratorError>.broadcast();
  final _isProcessing = ValueNotifier<bool>(false);
  bool _disposed = false;

  @override
  Stream<AgentToRendererMessage> get a2uiMessageStream =>
      _a2uiMessageController.stream;

  @override
  Stream<String> get textResponseStream => _textResponseController.stream;

  @override
  Stream<ContentGeneratorError> get errorStream => _errorController.stream;

  @override
  ValueListenable<bool> get isProcessing => _isProcessing;

  @override
  Future<void> sendRequest(String text) async {
    if (_disposed) return;
    _isProcessing.value = true;
    final pendingText = StringBuffer();
    final ContinuingResponseStream reply = _agent.openContinuingStream(
      state: _state,
    );

    void flushText() {
      final String pending = pendingText.toString().trim();
      pendingText.clear();
      if (pending.isNotEmpty && !_disposed) {
        _textResponseController.add(pending);
      }
    }

    void deliver(List<StreamPart> parts) {
      for (final StreamPart part in parts) {
        if (_disposed) return;
        switch (part) {
          case TextPart(text: final chunk):
            pendingText.write(chunk);
          case A2uiPart(:final a2ui):
            flushText();
            a2ui.forEach(_a2uiMessageController.add);
          case ErrorPart(:final error):
            flushText();
            _errorController.add(ContentGeneratorError(error));
        }
      }
    }

    try {
      _chat ??= FirebaseAI.googleAI()
          .generativeModel(
            model: 'gemini-2.5-flash',
            systemInstruction: Content.system(
              [systemInstruction, _agent.promptSnippet].nonNulls.join('\n\n'),
            ),
          )
          .startChat();
      await for (final response in _chat!.sendMessageStream(
        Content.text(text),
      )) {
        deliver(reply.feed(response.text ?? ''));
      }
      deliver(reply.close());
      flushText();
    } on A2uiError catch (e, st) {
      // The reply could not be read on; show what was read before the error.
      deliver(e.partialResults);
      flushText();
      if (!_disposed) _errorController.add(ContentGeneratorError(e, st));
    } catch (e, st) {
      debugPrint('FirebaseAiContentGenerator: Error generating content: $e');
      flushText();
      if (!_disposed) _errorController.add(ContentGeneratorError(e, st));
    } finally {
      if (!_disposed) _isProcessing.value = false;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _a2uiMessageController.close();
    _textResponseController.close();
    _errorController.close();
    _isProcessing.dispose();
  }
}
