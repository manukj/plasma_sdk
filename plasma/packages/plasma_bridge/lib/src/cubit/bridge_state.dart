import 'package:equatable/equatable.dart';

/// Represents the current state of the bridge connection
abstract class BridgeState extends Equatable {
  const BridgeState();

  @override
  List<Object?> get props => [];
}

/// Bridge is not initialized
class BridgeDisconnected extends BridgeState {
  const BridgeDisconnected();
}

/// Bridge is initializing
class BridgeConnecting extends BridgeState {
  const BridgeConnecting();
}

/// Bridge is initialized and ready
class BridgeConnected extends BridgeState {
  const BridgeConnected();
}

/// Bridge encountered an error
class BridgeError extends BridgeState {
  final String message;

  const BridgeError(this.message);

  @override
  List<Object?> get props => [message];
}
