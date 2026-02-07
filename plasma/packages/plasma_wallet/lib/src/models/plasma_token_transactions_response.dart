import 'plasma_token_transaction.dart';

class PlasmaTokenTransactionsResponse {
  const PlasmaTokenTransactionsResponse({
    required this.status,
    required this.message,
    required this.result,
  });

  final String status;
  final String message;
  final List<PlasmaTokenTransaction> result;

  bool get isSuccess => status == '1';
}
