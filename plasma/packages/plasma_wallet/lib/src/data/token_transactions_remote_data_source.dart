import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/plasma_token_transactions_response_model.dart';

class TokenTransactionsRemoteDataSource {
  TokenTransactionsRemoteDataSource({
    required String apiBaseUrl,
    required String apiKey,
    required String contractAddress,
    required int chainId,
    http.Client? client,
  })  : _apiBaseUrl = apiBaseUrl,
        _apiKey = apiKey,
        _contractAddress = contractAddress,
        _chainId = chainId,
        _client = client ?? http.Client();

  final String _apiBaseUrl;
  final String _apiKey;
  final String _contractAddress;
  final int _chainId;
  final http.Client _client;

  Future<PlasmaTokenTransactionsResponseModel> getAddressTransactions({
    required String address,
    int number = 10,
  }) async {
    final safeNumber = number <= 0 ? 10 : number;

    final uri = Uri.parse(_apiBaseUrl).replace(
      queryParameters: {
        'contractaddress': _contractAddress,
        'chainid': _chainId.toString(),
        'apikey': _apiKey,
        'address': address,
        'action': 'tokentx',
        'module': 'account',
        'offset': safeNumber.toString(),
        'sort': 'desc',
      },
    );

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Token transactions request failed (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid token transactions response format');
    }

    return PlasmaTokenTransactionsResponseModel.fromJson(body);
  }
}
