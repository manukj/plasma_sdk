import 'plasma_token_transaction.dart';
import 'plasma_token_transaction_model.dart';
import 'plasma_token_transactions_response.dart';

class PlasmaTokenTransactionsResponseModel
    extends PlasmaTokenTransactionsResponse {
  const PlasmaTokenTransactionsResponseModel({
    required super.status,
    required super.message,
    required super.result,
  });

  factory PlasmaTokenTransactionsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final status = _parseString(json['status']);
    final message = _parseString(json['message']);
    final resultRaw = json['result'];

    final result = <PlasmaTokenTransaction>[];
    if (resultRaw is List) {
      for (final item in resultRaw) {
        if (item is Map) {
          result.add(
            PlasmaTokenTransactionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return PlasmaTokenTransactionsResponseModel(
      status: status,
      message: message,
      result: List.unmodifiable(result),
    );
  }

  static String _parseString(Object? value) {
    if (value is String) return value;
    return '';
  }
}
