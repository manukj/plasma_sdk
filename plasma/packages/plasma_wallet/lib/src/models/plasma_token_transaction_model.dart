import 'plasma_token_transaction.dart';

class PlasmaTokenTransactionModel extends PlasmaTokenTransaction {
  const PlasmaTokenTransactionModel({
    required super.blockNumber,
    required super.timeStamp,
    required super.hash,
    required super.nonce,
    required super.blockHash,
    required super.from,
    required super.contractAddress,
    required super.to,
    required super.value,
    required super.tokenName,
    required super.tokenSymbol,
    required super.tokenDecimal,
    required super.transactionIndex,
    required super.gas,
    required super.gasPrice,
    required super.gasUsed,
    required super.cumulativeGasUsed,
    required super.input,
    required super.methodId,
    required super.functionName,
    required super.confirmations,
  });

  factory PlasmaTokenTransactionModel.fromJson(Map<String, dynamic> json) {
    return PlasmaTokenTransactionModel(
      blockNumber: _parseInt(json['blockNumber']),
      timeStamp: _parseInt(json['timeStamp']),
      hash: _parseString(json['hash']),
      nonce: _parseInt(json['nonce']),
      blockHash: _parseString(json['blockHash']),
      from: _parseString(json['from']),
      contractAddress: _parseString(json['contractAddress']),
      to: _parseString(json['to']),
      value: _parseBigInt(json['value']),
      tokenName: _parseString(json['tokenName']),
      tokenSymbol: _parseString(json['tokenSymbol']),
      tokenDecimal: _parseInt(json['tokenDecimal']),
      transactionIndex: _parseInt(json['transactionIndex']),
      gas: _parseBigInt(json['gas']),
      gasPrice: _parseBigInt(json['gasPrice']),
      gasUsed: _parseBigInt(json['gasUsed']),
      cumulativeGasUsed: _parseBigInt(json['cumulativeGasUsed']),
      input: _parseString(json['input']),
      methodId: _parseString(json['methodId']),
      functionName: _parseString(json['functionName']),
      confirmations: _parseInt(json['confirmations']),
    );
  }

  static int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static BigInt _parseBigInt(Object? value) {
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    if (value is String) return BigInt.tryParse(value) ?? BigInt.zero;
    return BigInt.zero;
  }

  static String _parseString(Object? value) {
    if (value is String) return value;
    return '';
  }
}
