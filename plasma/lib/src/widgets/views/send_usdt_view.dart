import 'package:flutter/material.dart';
import 'package:plasma/plasma.dart';

enum _SendState { input, sending, success, error }

class PlasmaSendUSDTView extends StatefulWidget {
  const PlasmaSendUSDTView({super.key});

  @override
  State<PlasmaSendUSDTView> createState() => _PlasmaSendUSDTViewState();
}

class _PlasmaSendUSDTViewState extends State<PlasmaSendUSDTView> {
  _SendState _state = _SendState.input;
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  String? _txHash;
  String? _errorMessage;

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PlasmaTheme.spacingXl),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send Money',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingSm),
        const Text(
          'Transfer funds instantly to any address.',
          style: TextStyle(fontSize: 16, color: PlasmaTheme.textSecondary),
        ),
        const SizedBox(height: PlasmaTheme.spacing2xl),

        // To Address Field
        const Text(
          'To',
          style: TextStyle(
            fontSize: 16,
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
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingXl),

        // Amount Field
        const Text(
          'Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PlasmaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingSm),
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
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 32,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: PlasmaTheme.spacingMd,
                      vertical: PlasmaTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(PlasmaTheme.radiusSm),
                    ),
                    child: const Text(
                      'USDT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PlasmaTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PlasmaTheme.spacingSm),
              const Text(
                '\$0.00 USD',
                style: TextStyle(fontSize: 14, color: PlasmaTheme.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacingXl),

        // Info Cards
        _buildInfoCard(
          icon: Icons.electric_bolt_outlined,
          title: 'Network Fee',
          subtitle: 'Plasma chain offers zero-fee transfers',
          value: 'Free',
        ),
        const SizedBox(height: PlasmaTheme.spacingMd),
        _buildInfoCard(
          icon: Icons.speed,
          title: 'Estimated Time',
          subtitle: 'Finality is near-instant',
          value: '< 2s',
        ),
        const SizedBox(height: PlasmaTheme.spacing2xl),

        // Send Button
        PlasmaButton(text: 'Send', icon: Icons.send, onPressed: _send),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(PlasmaTheme.spacingLg),
      decoration: BoxDecoration(
        color: PlasmaTheme.background,
        borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
        border: Border.all(color: PlasmaTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: PlasmaTheme.textSecondary, size: 24),
          const SizedBox(width: PlasmaTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PlasmaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PlasmaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PlasmaTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: PlasmaTheme.spacing3xl),
      child: PlasmaLoadingWidget(
        message: 'Sending USDT...',
        subtitle: 'PROCESSING TRANSACTION',
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
            color: PlasmaTheme.success,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Hash',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PlasmaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: PlasmaTheme.spacingSm),
                SelectableText(
                  _txHash!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: PlasmaTheme.textPrimary,
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
