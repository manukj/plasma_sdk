import { createWalletClient, http, parseUnits } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { defineChain } from 'viem';

const plasmaTestnet = defineChain({
  id: 9746,
  name: 'Plasma Testnet',
  network: 'plasma-testnet',
  nativeCurrency: { name: 'Plasma', symbol: 'XPL', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://testnet-rpc.plasma.to'] },
    public: { http: ['https://testnet-rpc.plasma.to'] },
  },
});

const EIP3009_TYPES = {
  ReceiveWithAuthorization: [
    { name: 'from', type: 'address' },
    { name: 'to', type: 'address' },
    { name: 'value', type: 'uint256' },
    { name: 'validAfter', type: 'uint256' },
    { name: 'validBefore', type: 'uint256' },
    { name: 'nonce', type: 'bytes32' },
  ],
};

const randomNonce32 = () => {
  if (
    !globalThis.crypto ||
    typeof globalThis.crypto.getRandomValues !== 'function'
  ) {
    throw new Error('Secure random generator unavailable in this WebView');
  }

  const bytes = new Uint8Array(32);
  globalThis.crypto.getRandomValues(bytes);
  return (
    '0x' +
    Array.from(bytes)
      .map((byte) => byte.toString(16).padStart(2, '0'))
      .join('')
  );
};

window.bridge = {
  ping: () => 'pong',

  signGaslessTransfer: async (privateKey, from, to, amount, tokenAddress) => {
    try {
      const account = privateKeyToAccount(privateKey);
      const client = createWalletClient({
        account,
        chain: plasmaTestnet,
        transport: http(),
      });

      const validAfter = BigInt(0);
      const validBefore = BigInt(Math.floor(Date.now() / 1000) + 3600);
      const nonce = randomNonce32();
      const value = parseUnits(amount, 6);

      const signature = await client.signTypedData({
        account,
        domain: {
          name: 'USD Token',
          version: '1',
          chainId: 9746,
          verifyingContract: tokenAddress,
        },
        types: EIP3009_TYPES,
        primaryType: 'ReceiveWithAuthorization',
        message: {
          from,
          to,
          value,
          validAfter,
          validBefore,
          nonce,
        },
      });

      return JSON.stringify({
        authorization: {
          from,
          to,
          value: value.toString(),
          validAfter: validAfter.toString(),
          validBefore: validBefore.toString(),
          nonce,
        },
        signature: signature,
      });
    } catch (e) {
      return 'ERROR: ' + e.message;
    }
  },
};

console.log('✅ Offline Bridge Logic Loaded');
