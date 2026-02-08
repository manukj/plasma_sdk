import 'package:equatable/equatable.dart';

import 'chat_message.dart';

enum PlasmaFeedItemType {
  message,
  surface,
}

class PlasmaFeedItem extends Equatable {
  final PlasmaFeedItemType type;
  final PlasmaMessage? message;
  final String? surfaceId;

  const PlasmaFeedItem._({
    required this.type,
    this.message,
    this.surfaceId,
  });

  factory PlasmaFeedItem.message(PlasmaMessage message) {
    return PlasmaFeedItem._(
      type: PlasmaFeedItemType.message,
      message: message,
    );
  }

  factory PlasmaFeedItem.surface(String surfaceId) {
    return PlasmaFeedItem._(
      type: PlasmaFeedItemType.surface,
      surfaceId: surfaceId,
    );
  }

  bool get isMessage => type == PlasmaFeedItemType.message;
  bool get isSurface => type == PlasmaFeedItemType.surface;

  @override
  List<Object?> get props => [type, message, surfaceId];
}
