import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../plasma.dart';

enum _WalletSheetState { initial, loading, success }

Future<void> showCreateWalletSheet(BuildContext context) async {
  if (!Plasma.instance.isInitialized) {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('SDK Not Initialized'),
          content: const Text(
            'Please initialize Plasma SDK first by calling Plasma.instance.init()',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return;
  }

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) => const _CreateWalletSheet(),
  );
}

class _CreateWalletSheet extends StatefulWidget {
  const _CreateWalletSheet();

  @override
  State<_CreateWalletSheet> createState() => _CreateWalletSheetState();
}

class _CreateWalletSheetState extends State<_CreateWalletSheet> {
  _WalletSheetState _state = _WalletSheetState.initial;
  String? _address;

  Future<void> _createWallet() async {
    setState(() => _state = _WalletSheetState.loading);

    try {
      await Future.delayed(const Duration(seconds: 1));
      await Plasma.instance.createWallet();
      _address = Plasma.instance.address;

      setState(() => _state = _WalletSheetState.success);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create wallet: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _copyAddress() {
    if (_address != null) {
      Clipboard.setData(ClipboardData(text: _address!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PlasmaTheme.radius2xl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PlasmaTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PlasmaTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: PlasmaTheme.spacingMd),
              if (_state == _WalletSheetState.initial) _buildInitialState(),
              if (_state == _WalletSheetState.loading) _buildLoadingState(),
              if (_state == _WalletSheetState.success) _buildSuccessState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'packages/plasma/assets/images/logo.png',
              width: 128,
              height: 40,
              fit: BoxFit.contain,
            ),
            const Text(
              ' Wallet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PlasmaTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: PlasmaTheme.spacingMd),
        const Text(
          'The secure gateway to the Plasma ecosystem. Create your self-custodial wallet to get started.',
          style: TextStyle(
            fontSize: 16,
            color: PlasmaTheme.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PlasmaTheme.spacing2xl),
        const PlasmaFeatureCard(
          icon: Icons.security,
          title: 'Military-grade Security',
          description: 'Your keys never leave your device.',
        ),
        const SizedBox(height: PlasmaTheme.spacingMd),
        const PlasmaFeatureCard(
          icon: Icons.flash_on,
          title: 'Instant Setup',
          description: 'Ready for the blockchain in seconds.',
        ),
        const SizedBox(height: PlasmaTheme.spacing2xl),
        PlasmaButton(
          text: 'Create Wallet',
          icon: Icons.account_balance_wallet,
          onPressed: _createWallet,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: PlasmaTheme.spacing3xl),
      child: PlasmaLoadingWidget(
        message: 'Creating your secure wallet...',
        subtitle: 'SECURING KEYS',
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          width: PlasmaTheme.iconContainerLg,
          height: PlasmaTheme.iconContainerLg,
          decoration: BoxDecoration(
            color: PlasmaTheme.primary,
            borderRadius: BorderRadius.circular(PlasmaTheme.radiusXl),
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: PlasmaTheme.iconXl,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingXl),
        const Text(
          'Wallet Created!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingMd),
        const Text(
          'Your wallet has been created successfully. Keep your device secure.',
          style: TextStyle(
            fontSize: 16,
            color: PlasmaTheme.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PlasmaTheme.spacing2xl),
        Container(
          padding: const EdgeInsets.all(PlasmaTheme.spacingLg),
          decoration: BoxDecoration(
            color: PlasmaTheme.background,
            borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
            border: Border.all(color: PlasmaTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wallet Address',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PlasmaTheme.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: _copyAddress,
                    icon: const Icon(Icons.copy, size: PlasmaTheme.iconSm),
                    tooltip: 'Copy address',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: PlasmaTheme.spacingSm),
              SelectableText(
                _address ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: PlasmaTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingXl),
        PlasmaButton(text: 'Done', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
