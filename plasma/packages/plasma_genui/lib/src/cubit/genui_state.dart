import 'package:equatable/equatable.dart';

import '../models/chat_feed_item.dart';

abstract class GenUiState extends Equatable {
  const GenUiState();

  @override
  List<Object?> get props => [];
}

class GenUiInitial extends GenUiState {
  const GenUiInitial();
}

class GenUiLoading extends GenUiState {
  final List<PlasmaFeedItem> items;

  const GenUiLoading({
    required this.items,
  });

  @override
  List<Object?> get props => [items];
}

class GenUiMessageReceived extends GenUiState {
  final List<PlasmaFeedItem> items;

  const GenUiMessageReceived({
    required this.items,
  });

  @override
  List<Object?> get props => [items];
}

/// State when a surface is added
class GenUiSurfaceAdded extends GenUiState {
  final List<PlasmaFeedItem> items;

  const GenUiSurfaceAdded({
    required this.items,
  });

  @override
  List<Object?> get props => [items];
}

/// Error state
class GenUiError extends GenUiState {
  final String message;
  final List<PlasmaFeedItem> items;

  const GenUiError({
    required this.message,
    required this.items,
  });

  @override
  List<Object?> get props => [message, items];
}
