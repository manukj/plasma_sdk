import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../plasma.dart';

class PlasmaTranscationHistory extends StatefulWidget {
  const PlasmaTranscationHistory({super.key, this.number = 10});

  final int number;

  @override
  State<PlasmaTranscationHistory> createState() =>
      _PlasmaTranscationHistoryState();
}

class _PlasmaTranscationHistoryState extends State<PlasmaTranscationHistory> {
  bool _isLoading = true;
  String? _error;
  List<PlasmaTokenTransaction> _transactions = const [];
  Future<void>? _activeLoad;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void didUpdateWidget(covariant PlasmaTranscationHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    if (_activeLoad != null) {
      await _activeLoad;
      return;
    }

    final load = _performLoad();
    _activeLoad = load;
    await load.whenComplete(() {
      _activeLoad = null;
    });
  }

  Future<void> _performLoad() async {
    if (!Plasma.instance.isInitialized || !Plasma.instance.hasWallet) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _transactions = const [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await Plasma.instance.getTokenTransactions(
        widget.number,
      );
      if (!mounted) return;

      if (!response.isSuccess && response.result.isEmpty) {
        setState(() {
          _transactions = const [];
          _isLoading = false;
          _error = response.message.isEmpty
              ? 'Failed to load transactions'
              : response.message;
        });
        return;
      }

      setState(() {
        _transactions = response.result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _transactions = const [];
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _copyHash(String hash) {
    Clipboard.setData(ClipboardData(text: hash));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction hash copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Plasma.instance.isInitialized) {
      return _buildInfoCard(
        title: 'SDK Not Initialized',
        subtitle: 'Call Plasma.instance.init() first.',
      );
    }

    if (!Plasma.instance.hasWallet) {
      return _buildInfoCard(
        title: 'No Wallet',
        subtitle: 'Create or load a wallet to view transactions.',
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlasmaTheme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PlasmaTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: PlasmaTheme.primary),
                const SizedBox(width: PlasmaTheme.spacingSm),
                Expanded(
                  child: Text(
                    'USDT0 Transaction History (${widget.number})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: PlasmaTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _loadTransactions,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: PlasmaTheme.spacingMd),
            if (_isLoading)
              const PlasmaLoadingWidget(
                size: 40,
                message: 'Loading Transactions',
                subtitle: 'USDT0 HISTORY',
              ),
            if (!_isLoading && _error != null)
              _buildInfoCard(title: 'Failed to load', subtitle: _error!),
            if (!_isLoading && _error == null && _transactions.isEmpty)
              _buildInfoCard(
                title: 'No transactions found',
                subtitle: 'No USDT0 transactions for this wallet yet.',
              ),
            if (!_isLoading && _error == null && _transactions.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: PlasmaTheme.spacingSm),
                itemBuilder: (context, index) =>
                    _buildTransactionTile(_transactions[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(PlasmaTokenTransaction tx) {
    final myAddress = Plasma.instance.address?.toLowerCase();
    final isOutgoing = tx.from.toLowerCase() == myAddress;
    final direction = isOutgoing ? 'Sent' : 'Received';
    final counterparty = isOutgoing ? tx.to : tx.from;
    final amount = _formatTokenAmount(tx.value, tx.tokenDecimal);

    return Container(
      padding: const EdgeInsets.all(PlasmaTheme.spacingMd),
      decoration: BoxDecoration(
        color: PlasmaTheme.background,
        borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
        border: Border.all(color: PlasmaTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isOutgoing ? PlasmaTheme.error : PlasmaTheme.success)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18,
              color: isOutgoing ? PlasmaTheme.error : PlasmaTheme.success,
            ),
          ),
          const SizedBox(width: PlasmaTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$direction • Block ${tx.blockNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PlasmaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _truncate(counterparty),
                  style: const TextStyle(
                    fontSize: 12,
                    color: PlasmaTheme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _truncate(tx.hash),
                        style: const TextStyle(
                          fontSize: 11,
                          color: PlasmaTheme.textTertiary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _copyHash(tx.hash),
                      child: const Icon(
                        Icons.copy,
                        size: 14,
                        color: PlasmaTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(tx.timeStamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: PlasmaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PlasmaTheme.spacingSm),
          Text(
            '$amount ${tx.tokenSymbol}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PlasmaTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlasmaTheme.spacingMd),
      decoration: BoxDecoration(
        color: PlasmaTheme.background,
        borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
        border: Border.all(color: PlasmaTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PlasmaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: PlasmaTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _truncate(String value) {
    if (value.length <= 14) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
  }

  String _formatTimestamp(int seconds) {
    if (seconds <= 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    ).toLocal();
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  String _formatTokenAmount(BigInt value, int decimals) {
    if (decimals <= 0) return value.toString();

    final divisor = BigInt.from(10).pow(decimals);
    final whole = value ~/ divisor;
    final fractionRaw = (value % divisor).toString().padLeft(decimals, '0');
    var fraction = fractionRaw.replaceFirst(RegExp(r'0+$'), '');
    if (fraction.length > 4) {
      fraction = fraction.substring(0, 4);
    }

    if (fraction.isEmpty) return whole.toString();
    return '$whole.$fraction';
  }
}
