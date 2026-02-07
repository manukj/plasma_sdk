import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plasma/plasma.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize on Testnet
  await Plasma.instance.init(isTestnet: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _walletStatus = "Checking Wallet...";
  String _balance = "---";
  bool _isLoadingBalance = false;
  String _bridgeStatus = "Testing...";
  String _txStatus = "Ready to sign";
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _checkWallet();
    _testBridge();
  }

  void _checkWallet() {
    setState(() {
      if (Plasma.instance.wallet.isLoaded) {
        _walletStatus = "Wallet Loaded";
      } else {
        _walletStatus = "No Wallet Found";
        _balance = "---";
      }
    });
  }

  Future<void> _create() async {
    await Plasma.instance.wallet.create();
    _checkWallet();
  }

  Future<void> _clear() async {
    await Plasma.instance.wallet.clear();
    _checkWallet();
  }

  Future<void> _getBalance() async {
    if (!Plasma.instance.wallet.isLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Create a wallet first!')));
      return;
    }

    setState(() {
      _isLoadingBalance = true;
    });

    try {
      final balance = await Plasma.instance.wallet.getNativeBalance();
      setState(() {
        _balance = balance;
        _isLoadingBalance = false;
      });
    } catch (e) {
      setState(() {
        _balance = "Error: $e";
        _isLoadingBalance = false;
      });
    }
  }

  Future<void> _testBridge() async {
    try {
      final response = await Plasma.instance.bridge.ping();
      setState(() {
        _bridgeStatus = response == "pong"
            ? "✅ Connected"
            : "❌ Failed: $response";
      });
    } catch (e) {
      setState(() {
        _bridgeStatus = "❌ Error: $e";
      });
    }
  }

  Future<void> _sendGasless() async {
    if (!Plasma.instance.wallet.isLoaded) return;

    setState(() {
      _isSending = true;
      _txStatus = "⏳ Signing...";
    });

    try {
      final credentials = Plasma.instance.wallet.credentials;
      if (credentials is! EthPrivateKey) {
        throw "Invalid credentials type";
      }

      final privateKey =
          '0x${credentials.privateKeyInt.toRadixString(16).padLeft(64, '0')}';
      final myAddress = Plasma.instance.wallet.address!;

      final jsonString = await Plasma.instance.bridge.signGaslessTransfer(
        privateKey: privateKey,
        from: myAddress,
        to: "0x000000000000000000000000000000000000dEaD",
        amount: "1.0",
        tokenAddress: Plasma.instance.usdtAddress,
      );

      if (jsonString == null || jsonString.startsWith("ERROR:")) {
        setState(() {
          _txStatus = "❌ Signing Failed:\n${jsonString ?? 'No response'}";
          _isSending = false;
        });
        return;
      }

      setState(() {
        _txStatus = "⏳ Relaying...";
      });

      final signedData = jsonDecode(jsonString) as Map<String, dynamic>;
      final result = await PlasmaApi.submitGaslessTransfer(signedData);

      setState(() {
        _txStatus = result;
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        _txStatus = "❌ Exception: $e";
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = Plasma.instance.wallet;
    final network = Plasma.instance.isTestnet ? "Testnet" : "Mainnet";

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Plasma SDK Demo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Network Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Plasma.instance.isTestnet
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Plasma.instance.isTestnet
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      network,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Plasma.instance.isTestnet
                            ? Colors.orange.shade900
                            : Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transaction Test Card
              Card(
                elevation: 2,
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.send, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            'Gasless Signature Test',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (wallet.isLoaded) ...[
                        Text(
                          _txStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: _txStatus.startsWith('✅')
                                ? Colors.green
                                : _txStatus.startsWith('❌')
                                ? Colors.red
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendGasless,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            child: _isSending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Send Gasless (1.0 USDT0)'),
                          ),
                        ),
                      ] else
                        const Text(
                          'Create wallet to test transactions',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Wallet Status Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            wallet.isLoaded
                                ? Icons.account_balance_wallet
                                : Icons.warning_amber,
                            color: wallet.isLoaded ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _walletStatus,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (wallet.isLoaded) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Address:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          wallet.address ?? '',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bridge Status Card
              Card(
                elevation: 2,
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Text(
                        'Bridge Status:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_bridgeStatus, style: const TextStyle(fontSize: 14)),
                      const Spacer(),
                      IconButton(
                        onPressed: _testBridge,
                        icon: const Icon(Icons.refresh, size: 18),
                        tooltip: 'Test Bridge',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // USDT Balance Card
              if (wallet.isLoaded) ...[
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'XPL Balance',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _isLoadingBalance
                                ? const CircularProgressIndicator()
                                : Text(
                                    '\$$_balance',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            IconButton(
                              onPressed: _isLoadingBalance ? null : _getBalance,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh Balance',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              if (!wallet.isLoaded) ...[
                ElevatedButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Wallet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _isLoadingBalance ? null : _getBalance,
                  icon: _isLoadingBalance
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.account_balance),
                  label: const Text('Get XPL Balance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                // OutlinedButton.icon(
                //   onPressed: _clear,
                //   icon: const Icon(Icons.delete_outline),
                //   label: const Text('Delete Wallet'),
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: Colors.red,
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //   ),
                // ),
              ],

              const SizedBox(height: 32),

              // Info Card
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Info',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Wallet keys are stored securely in ${Theme.of(context).platform == TargetPlatform.iOS ? 'iOS Keychain' : 'Android Keystore'}\n'
                        '• XPL is the native token of Plasma Network\n'
                        '• Balance shows 0.0000 if wallet has no funds',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
