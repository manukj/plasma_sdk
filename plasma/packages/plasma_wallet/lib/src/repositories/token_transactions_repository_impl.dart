import '../data/token_transactions_remote_data_source.dart';
import '../models/plasma_token_transactions_response.dart';
import 'token_transactions_repository.dart';

class TokenTransactionsRepositoryImpl implements TokenTransactionsRepository {
  TokenTransactionsRepositoryImpl(this._remoteDataSource);

  final TokenTransactionsRemoteDataSource _remoteDataSource;

  @override
  Future<PlasmaTokenTransactionsResponse> getAddressTransactions({
    required String address,
    int number = 10,
  }) {
    return _remoteDataSource.getAddressTransactions(
      address: address,
      number: number,
    );
  }
}
