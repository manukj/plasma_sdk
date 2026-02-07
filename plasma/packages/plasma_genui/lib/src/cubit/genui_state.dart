import 'package:equatable/equatable.dart';

import '../models/chat_message.dart';

abstract class GenUiState extends Equatable {
  const GenUiState();

  @override
  List<Object?> get props => [];
}

class GenUiInitial extends GenUiState {
  const GenUiInitial();
}

class GenUiLoading extends GenUiState {
  final List<PlasmaMessage> messages;
  final List<String> surfaceIds;

  const GenUiLoading({
    required this.messages,
    required this.surfaceIds,
  });

  @override
  List<Object?> get props => [messages, surfaceIds];
}

class GenUiMessageReceived extends GenUiState {
  final List<PlasmaMessage> messages;
  final List<String> surfaceIds;

  const GenUiMessageReceived({
    required this.messages,
    required this.surfaceIds,
  });

  @override
  List<Object?> get props => [messages, surfaceIds];
}

/// State when a surface is added
class GenUiSurfaceAdded extends GenUiState {
  final List<PlasmaMessage> messages;
  final List<String> surfaceIds;

  const GenUiSurfaceAdded({
    required this.messages,
    required this.surfaceIds,
  });

  @override
  List<Object?> get props => [messages, surfaceIds];
}

/// Error state
class GenUiError extends GenUiState {
  final String message;
  final List<PlasmaMessage> messages;
  final List<String> surfaceIds;

  const GenUiError({
    required this.message,
    required this.messages,
    required this.surfaceIds,
  });

  @override
  List<Object?> get props => [message, messages, surfaceIds];
}
