class PlasmaTokenTransaction {
  const PlasmaTokenTransaction({
    required this.blockNumber,
    required this.timeStamp,
    required this.hash,
    required this.nonce,
    required this.blockHash,
    required this.from,
    required this.contractAddress,
    required this.to,
    required this.value,
    required this.tokenName,
    required this.tokenSymbol,
    required this.tokenDecimal,
    required this.transactionIndex,
    required this.gas,
    required this.gasPrice,
    required this.gasUsed,
    required this.cumulativeGasUsed,
    required this.input,
    required this.methodId,
    required this.functionName,
    required this.confirmations,
  });

  final int blockNumber;
  final int timeStamp;
  final String hash;
  final int nonce;
  final String blockHash;
  final String from;
  final String contractAddress;
  final String to;
  final BigInt value;
  final String tokenName;
  final String tokenSymbol;
  final int tokenDecimal;
  final int transactionIndex;
  final BigInt gas;
  final BigInt gasPrice;
  final BigInt gasUsed;
  final BigInt cumulativeGasUsed;
  final String input;
  final String methodId;
  final String functionName;
  final int confirmations;
}
