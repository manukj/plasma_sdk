enum Network { testnet, mainnet }

class NetworkConfig {
  final String name;
  final String rpcUrl;
  final String usdtAddress;
  final String relayerUrl;
  final int chainId;

  const NetworkConfig({
    required this.name,
    required this.rpcUrl,
    required this.usdtAddress,
    required this.relayerUrl,
    required this.chainId,
  });

  static const NetworkConfig testnet = NetworkConfig(
    name: "Plasma Testnet",
    rpcUrl: "https://testnet-rpc.plasma.to",
    usdtAddress: "0x246a94a471348881071bb475bf318b7119ab7e2d",
    relayerUrl: "https://api.relayer.plasma.to",
    chainId: 9746,
  );

  static const NetworkConfig mainnet = NetworkConfig(
    name: "Plasma Mainnet",
    rpcUrl: "https://rpc.plasma.to",
    usdtAddress:
        "0xTODO_MAINNET_USDT_ADDRESS", // TODO: Update with actual mainnet USDT address
    relayerUrl: "https://api.relayer.plasma.to",
    chainId: 9747, // TODO: Update with actual mainnet chain ID
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
