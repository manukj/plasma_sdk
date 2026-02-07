import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../plasma.dart';

class PlasmaWalletCard extends StatefulWidget {
  const PlasmaWalletCard({super.key});

  @override
  State<PlasmaWalletCard> createState() => _PlasmaWalletCardState();
}

class _PlasmaWalletCardState extends State<PlasmaWalletCard> {
  String _balance = '---';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    if (!Plasma.instance.isInitialized || !Plasma.instance.hasWallet) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final balance = await Plasma.instance.getBalance();
      if (mounted) {
        setState(() {
          _balance = balance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _balance = 'Error';
          _isLoading = false;
        });
      }
    }
  }

  String _truncateAddress(String addr) {
    if (addr.length <= 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  void _copyAddress(BuildContext context) {
    final address = Plasma.instance.address ?? '';
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Address copied!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: PlasmaTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if SDK is initialized
    if (!Plasma.instance.isInitialized) {
      return _buildErrorCard(
        'SDK Not Initialized',
        'Please initialize Plasma SDK first',
      );
    }

    // Check if wallet exists
    if (!Plasma.instance.hasWallet) {
      return _buildErrorCard('No Wallet', 'Create a wallet to view card');
    }

    final address = Plasma.instance.address ?? '';

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlasmaTheme.radiusLg),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1a1a1a), PlasmaTheme.primary],
          ),
          borderRadius: BorderRadius.circular(PlasmaTheme.radiusLg),
        ),
        padding: const EdgeInsets.all(PlasmaTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with chip icon and logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'packages/plasma/assets/images/chip_icon.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                Image.asset(
                  'packages/plasma/assets/images/logo_light.png',
                  width: 60,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: PlasmaTheme.spacingLg),

            // Balance section
            const Text(
              'USDT BALANCE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: PlasmaTheme.spacingXs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _isLoading
                      ? const SizedBox(
                          height: 28,
                          child: Center(
                            widthFactor: 1,
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          _balance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _loadBalance,
                  icon: Icon(
                    Icons.refresh,
                    color: _isLoading ? Colors.white38 : Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Refresh balance',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: PlasmaTheme.spacingLg),

            // Address section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PlasmaTheme.spacingMd,
                vertical: PlasmaTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(PlasmaTheme.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _truncateAddress(address),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: PlasmaTheme.spacingSm),
                  GestureDetector(
                    onTap: () => _copyAddress(context),
                    child: const Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String title, String message) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlasmaTheme.radiusLg),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a1a),
              PlasmaTheme.error.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(PlasmaTheme.radiusLg),
        ),
        padding: const EdgeInsets.all(PlasmaTheme.spacingLg),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: PlasmaTheme.error, size: 32),
            const SizedBox(width: PlasmaTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PlasmaTheme.spacingXs),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
