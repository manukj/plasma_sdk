import { createWalletClient, http, parseUnits, encodeFunctionData } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { defineChain } from 'viem';

// 1. Define Plasma Testnet Chain
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

// 2. Define the Bridge API
window.bridge = {
    // Simple connectivity test
    ping: () => "pong",

    // Send USDT Function
    sendUSDT: async (privateKey, to, amount, tokenAddress) => {
        try {
            console.log(`JS: Preparing to send ${amount} USDT to ${to}`);

            // Setup Account
            const account = privateKeyToAccount(privateKey);

            // Setup Client
            const client = createWalletClient({
                account,
                chain: plasmaTestnet,
                transport: http()
            });

            // Encode Transaction (ERC20 Transfer)
            // Assuming USDT has 6 decimals. If 18, change to 18.
            const amountInWei = parseUnits(amount, 6);

            const data = encodeFunctionData({
                abi: [{
                    name: 'transfer',
                    type: 'function',
                    inputs: [{ name: 'to', type: 'address' }, { name: 'amount', type: 'uint256' }],
                    outputs: [{ name: '', type: 'bool' }]
                }],
                functionName: 'transfer',
                args: [to, amountInWei]
            });

            // Send Transaction
            const hash = await client.sendTransaction({
                account,
                to: tokenAddress,
                data: data,
                value: 0n // 0 XPL
            });

            console.log("JS: Transaction Sent! Hash: " + hash);
            return hash;

        } catch (e) {
            console.error("JS Error: ", e);
            return "ERROR: " + e.message;
        }
    }
};

console.log("✅ Offline Bridge Logic Loaded");
