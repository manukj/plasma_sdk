enum Network { testnet, mainnet }

class NetworkConfig {
  final String name;
  final String rpcUrl;
  final String usdt0Address;
  final String relayerUrl;
  final int chainId;
  final String etherscanApiBaseUrl;

  const NetworkConfig({
    required this.name,
    required this.rpcUrl,
    required this.usdt0Address,
    required this.relayerUrl,
    required this.chainId,
    required this.etherscanApiBaseUrl,
  });

  static const NetworkConfig testnet = NetworkConfig(
    name: "Plasma Testnet",
    rpcUrl: "https://testnet-rpc.plasma.to",
    usdt0Address: "0x502012b361AebCE43b26Ec812B74D9a51dB4D412",
    relayerUrl: "https://api.relayer.plasma.to",
    chainId: 9746,
    etherscanApiBaseUrl: "https://api.etherscan.io/v2/api",
  );

  static const NetworkConfig mainnet = NetworkConfig(
    name: "Plasma Mainnet",
    rpcUrl: "https://rpc.plasma.to",
    usdt0Address:
        "0xTODO_MAINNET_USDT0_ADDRESS", // TODO: Update with actual mainnet USDT0 address
    relayerUrl: "https://api.relayer.plasma.to",
    chainId: 9747, // TODO: Update with actual mainnet chain ID
    etherscanApiBaseUrl: "https://api.etherscan.io/v2/api",
  );

  static NetworkConfig getConfig(Network network) {
    switch (network) {
      case Network.testnet:
        return NetworkConfig.testnet;
      case Network.mainnet:
        return NetworkConfig.mainnet;
    }
  }

  @override
  String toString() => name;
}
