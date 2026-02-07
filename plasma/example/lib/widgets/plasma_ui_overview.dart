import 'package:flutter/material.dart';
import 'package:plasma/plasma.dart';

class PlasmaUiOverview extends StatefulWidget {
  const PlasmaUiOverview({super.key});

  @override
  State<PlasmaUiOverview> createState() => _PlasmaUiOverviewState();
}

class _PlasmaUiOverviewState extends State<PlasmaUiOverview> {
  bool get _hasWallet => Plasma.instance.hasWallet;

  Future<void> _openCreateWalletSheet() async {
    await showCreateWalletSheet(context);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadTestWallet() async {
    const testPrivateKey =
        '355c82a40060acd13e0fc5c03c8748ba6c2b82f31f759dd51bf97ae42537d932';

    try {
      await Plasma.instance.loadTestWallet(testPrivateKey);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test wallet loaded')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load test wallet: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showBottomSheet({
    required String title,
    required Widget child,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PlasmaTheme.radius2xl),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: PlasmaTheme.spacingMd,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PlasmaTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWalletCard() async {
    await _showBottomSheet(
      title: 'Plasma Wallet Card',
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: PlasmaWalletCard(),
      ),
    );
  }

  Future<void> _openTransactionHistory() async {
    await _showBottomSheet(
      title: 'Plasma Transaction History',
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: PlasmaTranscationHistory(number: 10),
      ),
    );
  }

  Future<void> _openSendPayment() async {
    await _showBottomSheet(
      title: 'Send Payment',
      child: const PaymentView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plasma UI Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use these ready UI components through bottom sheets for fast integration.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PlasmaButton(
            text: 'Create Wallet',
            icon: Icons.account_balance_wallet,
            onPressed: _openCreateWalletSheet,
          ),
          const SizedBox(height: 10),
          PlasmaButton(
            text: 'Load Test Wallet',
            icon: Icons.vpn_key,
            onPressed: _loadTestWallet,
          ),
          const SizedBox(height: 10),
          PlasmaButton(
            text: 'View Plasma Card',
            icon: Icons.credit_card,
            onPressed: _hasWallet ? _openWalletCard : null,
          ),
          const SizedBox(height: 10),
          PlasmaButton(
            text: 'View Transcation History',
            icon: Icons.receipt_long,
            onPressed: _hasWallet ? _openTransactionHistory : null,
          ),
          const SizedBox(height: 10),
          PlasmaButton(
            text: 'Send Payment',
            icon: Icons.send,
            onPressed: _hasWallet ? _openSendPayment : null,
          ),
          const SizedBox(height: 12),
          if (!_hasWallet)
            const Text(
              'Create wallet first to enable card, transaction history, and payment actions.',
              style: TextStyle(color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
