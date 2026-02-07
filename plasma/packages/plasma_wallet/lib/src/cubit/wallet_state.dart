import 'package:equatable/equatable.dart';

/// Represents the current state of the wallet
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

/// No wallet exists
class WalletNone extends WalletState {
  const WalletNone();
}

/// Wallet is being created
class WalletCreating extends WalletState {
  const WalletCreating();
}

/// Wallet exists and is ready
class WalletCreated extends WalletState {
  final String address;

  const WalletCreated(this.address);

  @override
  List<Object?> get props => [address];
}

/// Wallet operation encountered an error
class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
