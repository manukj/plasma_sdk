import 'package:equatable/equatable.dart';

class PlasmaMessage extends Equatable {
  final String text;
  final bool isUser;
  final bool isError;

  const PlasmaMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  List<Object?> get props => [text, isUser, isError];
}
