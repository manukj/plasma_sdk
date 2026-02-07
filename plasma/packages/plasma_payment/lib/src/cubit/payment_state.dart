import 'package:equatable/equatable.dart';

/// Represents the current state of payment operations
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Idle state, no operation in progress
class PaymentIdle extends PaymentState {
  final String balance;

  const PaymentIdle({this.balance = '0'});

  @override
  List<Object?> get props => [balance];
}

/// Loading balance or processing transaction
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Transaction successful
class PaymentSuccess extends PaymentState {
  final String txHash;
  final String balance;

  const PaymentSuccess({required this.txHash, this.balance = '0'});

  @override
  List<Object?> get props => [txHash, balance];
}

/// Payment operation encountered an error
class PaymentError extends PaymentState {
  final String message;
  final String balance;

  const PaymentError({required this.message, this.balance = '0'});

  @override
  List<Object?> get props => [message, balance];
}
