import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../plasma.dart';

enum _SendState { input, sending, success, error }

class PaymentView extends StatefulWidget {
  const PaymentView({
    super.key,
    this.toAddress,
    this.amount,
    this.compact = false,
  });

  final String? toAddress;
  final String? amount;
  final bool compact;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  _SendState _state = _SendState.input;
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  String? _txHash;
  String? _errorMessage;
  String _stableBalance = '---';
  bool _isLoadingStableBalance = false;
  bool _isAmountFocused = false;

  @override
  void initState() {
    super.initState();
    final initialToAddress = widget.toAddress?.trim();
    if (initialToAddress != null && initialToAddress.isNotEmpty) {
      _toController.text = initialToAddress;
    }

    final initialAmount = widget.amount?.trim();
    if (initialAmount != null && initialAmount.isNotEmpty) {
      _amountController.text = initialAmount;
    }

    _amountFocusNode.addListener(_onAmountFocusChanged);
    _loadStableBalance();
  }

  @override
  void dispose() {
    _amountFocusNode.removeListener(_onAmountFocusChanged);
    _amountFocusNode.dispose();
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PaymentView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextToAddress = widget.toAddress?.trim();
    if (nextToAddress != null &&
        nextToAddress.isNotEmpty &&
        nextToAddress != _toController.text) {
      _toController.text = nextToAddress;
    }

    final nextAmount = widget.amount?.trim();
    if (nextAmount != null &&
        nextAmount.isNotEmpty &&
        nextAmount != _amountController.text) {
      _amountController.text = nextAmount;
    }
  }

  void _onAmountFocusChanged() {
    if (!mounted) return;
    setState(() => _isAmountFocused = _amountFocusNode.hasFocus);
  }

  Future<void> _send() async {
    if (_toController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    setState(() => _state = _SendState.sending);

    try {
      final result = await Plasma.instance.sendUSDT(
        to: _toController.text.trim(),
        amount: _amountController.text.trim(),
      );

      setState(() {
        _state = _SendState.success;
        _txHash = result;
      });
    } catch (e) {
      setState(() {
        _state = _SendState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadStableBalance() async {
    if (!Plasma.instance.isInitialized || !Plasma.instance.hasWallet) {
      return;
    }

    setState(() => _isLoadingStableBalance = true);
    try {
      final balance = await Plasma.instance.getStableTokenBalance();
      if (!mounted) return;
      setState(() {
        _stableBalance = balance;
        _isLoadingStableBalance = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stableBalance = '0.0000';
        _isLoadingStableBalance = false;
      });
    }
  }

  Future<void> _openTransactionOnExplorer(String txHash) async {
    final baseUrl = "https://testnet.plasmascan.to";
    final url = Uri.parse('$baseUrl/tx/$txHash');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final outerPadding = widget.compact
        ? PlasmaTheme.spacingLg
        : PlasmaTheme.spacingXl;

    return Padding(
      padding: EdgeInsets.all(outerPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_state == _SendState.input) _buildInputState(),
          if (_state == _SendState.sending) _buildSendingState(),
          if (_state == _SendState.success) _buildSuccessState(),
          if (_state == _SendState.error) _buildErrorState(),
        ],
      ),
    );
  }

  Widget _buildInputState() {
    final titleSize = widget.compact ? 24.0 : 28.0;
    final fieldLabelSize = widget.compact ? 14.0 : 16.0;
    final amountTextSize = widget.compact ? 26.0 : 32.0;
    final amountContainerPadding = widget.compact
        ? PlasmaTheme.spacingMd
        : PlasmaTheme.spacingLg;
    final sectionGap = widget.compact
        ? PlasmaTheme.spacingLg
        : PlasmaTheme.spacingXl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send Money',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        SizedBox(
          height: widget.compact
              ? PlasmaTheme.spacingMd
              : PlasmaTheme.spacing2xl,
        ),

        // To Address Field
        Text(
          'To',
          style: TextStyle(
            fontSize: fieldLabelSize,
            fontWeight: FontWeight.w600,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingSm),
        TextField(
          controller: _toController,
          decoration: InputDecoration(
            hintText: 'Address, ENS or Name',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            suffixIcon: const Icon(
              Icons.qr_code_scanner_outlined,
              size: 20,
              color: PlasmaTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
              borderSide: BorderSide(color: PlasmaTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
              borderSide: BorderSide(color: PlasmaTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
              borderSide: BorderSide(color: PlasmaTheme.primary, width: 2),
            ),
            filled: true,
            fillColor: PlasmaTheme.background,
            isDense: widget.compact,
          ),
        ),
        SizedBox(height: sectionGap),

        // Amount Field
        Text(
          'Amount',
          style: TextStyle(
            fontSize: fieldLabelSize,
            fontWeight: FontWeight.w600,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingSm),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).requestFocus(_amountFocusNode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: EdgeInsets.all(amountContainerPadding),
            decoration: BoxDecoration(
              color: PlasmaTheme.background,
              borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
              border: Border.all(
                color: _isAmountFocused
                    ? PlasmaTheme.primary
                    : PlasmaTheme.border,
                width: _isAmountFocused ? 2 : 1,
              ),
              boxShadow: _isAmountFocused
                  ? [
                      BoxShadow(
                        color: PlasmaTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: amountTextSize,
                          fontWeight: FontWeight.w600,
                          color: PlasmaTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.compact
                            ? PlasmaTheme.spacingSm
                            : PlasmaTheme.spacingMd,
                        vertical: widget.compact
                            ? PlasmaTheme.spacingXs
                            : PlasmaTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          PlasmaTheme.radiusSm,
                        ),
                      ),
                      child: const Text(
                        'USDT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: PlasmaTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PlasmaTheme.spacingSm),
                Row(
                  children: [
                    Text(
                      _isLoadingStableBalance
                          ? 'Loading balance...'
                          : 'Balance: $_stableBalance USDT',
                      style: TextStyle(
                        fontSize: widget.compact ? 12 : 14,
                        color: PlasmaTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: PlasmaTheme.spacingSm),
                    GestureDetector(
                      onTap: _isLoadingStableBalance
                          ? null
                          : _loadStableBalance,
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: _isLoadingStableBalance
                            ? PlasmaTheme.textTertiary
                            : PlasmaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: widget.compact
              ? PlasmaTheme.spacingMd
              : PlasmaTheme.spacingLg,
        ),

        if (!widget.compact) ...[
          // Informational hints (non-interactive)
          _buildInfoHintRow(
            icon: Icons.electric_bolt_outlined,
            title: 'Network Fee',
            subtitle: 'Zero-fee transfers',
            value: 'Free',
          ),
          const SizedBox(height: 6),
          _buildInfoHintRow(
            icon: Icons.speed,
            title: 'Estimated Time',
            subtitle: 'Near-instant finality',
            value: '< 2s',
          ),
          const SizedBox(height: PlasmaTheme.spacingLg),
        ],

        // Send Button
        PlasmaButton(text: 'Send', icon: Icons.send, onPressed: _send),
      ],
    );
  }

  Widget _buildInfoHintRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PlasmaTheme.spacingXs,
        vertical: 2,
      ),
      child: Row(
        children: [
          Icon(icon, color: PlasmaTheme.textTertiary, size: 14),
          const SizedBox(width: PlasmaTheme.spacingSm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: PlasmaTheme.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: subtitle),
                ],
              ),
            ),
          ),
          const SizedBox(width: PlasmaTheme.spacingSm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PlasmaTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingState() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: widget.compact
              ? PlasmaTheme.spacingLg
              : PlasmaTheme.spacing3xl,
        ),
        child: const PlasmaLoadingWidget(
          message: 'Sending USDT...',
          subtitle: 'PROCESSING TRANSACTION',
        ),
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
          'Transaction Sent!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingMd),
        const Text(
          'Your transaction has been submitted successfully.',
          style: TextStyle(
            fontSize: 16,
            color: PlasmaTheme.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (_txHash != null) ...[
          const SizedBox(height: PlasmaTheme.spacing2xl),
          Container(
            padding: const EdgeInsets.all(PlasmaTheme.spacingLg),
            decoration: BoxDecoration(
              color: PlasmaTheme.background,
              borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
              border: Border.all(color: PlasmaTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Transaction',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PlasmaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: PlasmaTheme.spacingSm),

                GestureDetector(
                  onTap: () => _openTransactionOnExplorer(_txHash!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PlasmaTheme.spacingMd,
                      vertical: PlasmaTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(PlasmaTheme.radiusSm),
                      border: Border.all(color: PlasmaTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _shortHash(_txHash!), // 0xabc…789
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: PlasmaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: PlasmaTheme.spacingSm),
                        const Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: PlasmaTheme.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: PlasmaTheme.spacingXl),
        PlasmaButton(text: 'Done', onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  String _shortHash(String hash) =>
      '${hash.substring(0, 6)}…${hash.substring(hash.length - 4)}';

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          width: PlasmaTheme.iconContainerLg,
          height: PlasmaTheme.iconContainerLg,
          decoration: BoxDecoration(
            color: PlasmaTheme.error,
            borderRadius: BorderRadius.circular(PlasmaTheme.radiusXl),
          ),
          child: const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: PlasmaTheme.iconXl,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingXl),
        const Text(
          'Transaction Failed',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingMd),
        Text(
          _errorMessage ?? 'An error occurred',
          style: const TextStyle(
            fontSize: 16,
            color: PlasmaTheme.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PlasmaTheme.spacingXl),
        PlasmaButton(
          text: 'Try Again',
          onPressed: () => setState(() => _state = _SendState.input),
        ),
      ],
    );
  }
}
