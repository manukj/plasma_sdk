import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/wallet_module.dart';
import 'wallet_state.dart';

/// Cubit for managing wallet state
class WalletCubit extends Cubit<WalletState> {
  final WalletModule _walletModule;

  WalletCubit(this._walletModule) : super(const WalletNone()) {
    _checkExistingWallet();
  }

  /// Check if a wallet already exists and load it
  void _checkExistingWallet() {
    if (_walletModule.isLoaded && _walletModule.address != null) {
      emit(WalletCreated(_walletModule.address!));
      debugPrint('✅ WalletCubit: Existing wallet loaded');
    }
  }

  /// Create a new wallet
  Future<void> createWallet() async {
    if (state is WalletCreated) {
      debugPrint('⚠️ WalletCubit: Wallet already exists');
      return;
    }

    emit(const WalletCreating());

    try {
      final address = await _walletModule.create();
      emit(WalletCreated(address));
      debugPrint('✅ WalletCubit: Wallet created with address $address');
    } catch (e) {
      final errorMessage = 'Failed to create wallet: $e';
      emit(WalletError(errorMessage));
      debugPrint('❌ WalletCubit: $errorMessage');
    }
  }

  /// Get the current wallet address
  String? get address {
    final currentState = state;
    if (currentState is WalletCreated) {
      return currentState.address;
    }
    return null;
  }

  /// Check if wallet exists
  bool get hasWallet => state is WalletCreated;

  /// Get the underlying wallet module
  WalletModule get module => _walletModule;

  /// Manually recheck wallet status (useful after loading test address)
  void recheckWallet() {
    _checkExistingWallet();
  }
}
