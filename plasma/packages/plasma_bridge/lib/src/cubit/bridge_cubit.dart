import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../controllers/bridge_module.dart';
import 'bridge_state.dart';

/// Cubit for managing bridge connection state
class BridgeCubit extends Cubit<BridgeState> {
  final BridgeModule _bridgeModule;

  BridgeCubit(this._bridgeModule) : super(const BridgeDisconnected());

  /// Initialize the bridge connection
  Future<void> initialize() async {
    if (state is BridgeConnected) {
      debugPrint('🌉 BridgeCubit: Already connected');
      return;
    }

    emit(const BridgeConnecting());

    try {
      await _bridgeModule.init();
      emit(const BridgeConnected());
      debugPrint('✅ BridgeCubit: Connected successfully');
    } catch (e) {
      final errorMessage = 'Failed to initialize bridge: $e';
      emit(BridgeError(errorMessage));
      debugPrint('❌ BridgeCubit: $errorMessage');
    }
  }

  /// Ping the bridge to check connection
  Future<String> ping() async {
    if (state is! BridgeConnected) {
      throw StateError('Bridge not connected');
    }

    try {
      return await _bridgeModule.ping();
    } catch (e) {
      emit(BridgeError('Ping failed: $e'));
      rethrow;
    }
  }

  /// Get the underlying bridge module
  BridgeModule get module => _bridgeModule;

  /// Check if bridge is connected
  bool get isConnected => state is BridgeConnected;
}
