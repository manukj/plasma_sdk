import '../models/plasma_token_transactions_response.dart';

abstract class TokenTransactionsRepository {
  Future<PlasmaTokenTransactionsResponse> getAddressTransactions({
    required String address,
    int number,
  });
}
