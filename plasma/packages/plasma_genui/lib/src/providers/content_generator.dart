import 'package:a2ui_core/a2ui_core.dart';
import 'package:flutter/foundation.dart';

/// An error a [ContentGenerator] met while answering a request.
class ContentGeneratorError {
  const ContentGeneratorError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;
}

/// Answers the user's messages with text and A2UI messages.
abstract interface class ContentGenerator {
  /// The A2UI messages of the replies, in the order they arrive.
  Stream<AgentToRendererMessage> get a2uiMessageStream;

  /// The text of the replies, one event per run of text.
  Stream<String> get textResponseStream;

  /// The errors met while answering.
  Stream<ContentGeneratorError> get errorStream;

  /// Whether a request is being answered.
  ValueListenable<bool> get isProcessing;

  /// Sends the user's [text] and answers it on the streams.
  Future<void> sendRequest(String text);

  void dispose();
}
