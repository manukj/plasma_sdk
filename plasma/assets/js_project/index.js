import { ethers } from 'ethers';

const DEFAULT_RPC_URL = 'https://testnet-rpc.plasma.to';
const ERC20_ABI = [
  'function decimals() view returns (uint8)',
  'function transfer(address to, uint256 amount) returns (bool)',
];

window.bridge = {
  ping: () => 'pong',

  signGaslessTransfer: async (
    privateKey,
    from,
    to,
    amount,
    tokenAddress,
    rpcUrl
  ) => {
    try {
      const provider = new ethers.JsonRpcProvider(rpcUrl || DEFAULT_RPC_URL);
      const wallet = new ethers.Wallet(privateKey, provider);
      const token = new ethers.Contract(tokenAddress, ERC20_ABI, wallet);

      const expectedFrom = (from || '').toLowerCase();
      const actualFrom = wallet.address.toLowerCase();
      if (expectedFrom && expectedFrom !== actualFrom) {
        throw new Error(
          `from/privateKey mismatch: expected ${from}, got ${wallet.address}`
        );
      }

      const decimals = await token.decimals();
      const parsedAmount = ethers.parseUnits(amount, Number(decimals));
      const tx = await token.transfer(to, parsedAmount);
      const receipt = await tx.wait();

      return JSON.stringify({
        txHash: tx.hash,
        blockNumber: receipt?.blockNumber?.toString() ?? null,
        status: receipt?.status ?? null,
        from: wallet.address,
        to,
        value: parsedAmount.toString(),
        tokenAddress,
      });
    } catch (e) {
      return 'ERROR: ' + e.message;
    }
  },
};

console.log('✅ Offline Bridge Logic Loaded');
