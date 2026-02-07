import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../services/payment_service.dart';
import 'payment_state.dart';

/// Cubit for managing payment state
class PaymentCubit extends Cubit<PaymentState> {
  final PaymentService _paymentService;

  PaymentCubit(this._paymentService) : super(const PaymentIdle());

  /// Load USDT balance
  Future<void> loadBalance() async {
    emit(const PaymentLoading());

    try {
      final balance = await _paymentService.getBalance();
      emit(PaymentIdle(balance: balance));
      debugPrint('✅ PaymentCubit: Balance loaded: $balance');
    } catch (e) {
      final errorMessage = 'Failed to load balance: $e';
      emit(PaymentError(message: errorMessage));
      debugPrint('❌ PaymentCubit: $errorMessage');
    }
  }

  /// Send USDT to address
  Future<void> sendUSDT({
    required String to,
    required String amount,
  }) async {
    emit(const PaymentLoading());

    try {
      final txHash = await _paymentService.sendUSDT(to: to, amount: amount);

      // Reload balance after sending
      final balance = await _paymentService.getBalance();

      emit(PaymentSuccess(txHash: txHash, balance: balance));
      debugPrint('✅ PaymentCubit: Transaction successful: $txHash');
    } catch (e) {
      final errorMessage = 'Failed to send USDT: $e';
      final currentBalance = await _safeGetBalance();
      emit(PaymentError(message: errorMessage, balance: currentBalance));
      debugPrint('❌ PaymentCubit: $errorMessage');
    }
  }

  /// Get balance safely without changing state
  Future<String> _safeGetBalance() async {
    try {
      return await _paymentService.getBalance();
    } catch (e) {
      return '0';
    }
  }

  /// Get current balance from state
  String get balance {
    final currentState = state;
    if (currentState is PaymentIdle) return currentState.balance;
    if (currentState is PaymentSuccess) return currentState.balance;
    if (currentState is PaymentError) return currentState.balance;
    return '0';
  }

  /// Get the underlying payment service
  PaymentService get service => _paymentService;
}
