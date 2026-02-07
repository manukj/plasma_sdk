import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // --- Logic Helpers ---

  Future<void> _loadTransactions() async {
    if (_activeLoad != null) return;
    final load = _performLoad();
    _activeLoad = load;
    await load.whenComplete(() => _activeLoad = null);
  }

  Future<void> _performLoad() async {
    if (!Plasma.instance.isInitialized || !Plasma.instance.hasWallet) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _transactions = const [];
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

      if (!response.isSuccess) {
        setState(() {
          _isLoading = false;
          _error = response.message;
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
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _getRelativeTime(int seconds) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
    );
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'just now';
  }

  Future<void> _openExplorer(String hash) async {
    final url = Uri.parse('https://testnet.plasmascan.to/tx/$hash');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const PlasmaLoadingWidget(
            size: 50,
            message: "Loading transactions...",
          )
        else if (_error != null)
          Text('Error: $_error')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildTransactionTile(_transactions[index]),
          ),
      ],
    );
  }

  Widget _buildTransactionTile(PlasmaTokenTransaction tx) {
    final myAddress = Plasma.instance.address?.toLowerCase();
    final isIncoming = tx.to.toLowerCase() == myAddress;
    final amount = _formatTokenAmount(tx.value, tx.tokenDecimal);
    final symbol = tx.tokenSymbol.isEmpty ? 'USDT' : tx.tokenSymbol;
    final displayLabel = isIncoming ? 'From' : 'To';
    final displayAddress = isIncoming ? tx.from : tx.to;

    const addressTeal = Color(0xFF439696);
    const badgeGrey = Color(0xFFF2F4F7);
    const inBadgeGreen = Color(0xFFE6F9F3);
    const inTextGreen = Color(0xFF065F46);

    return InkWell(
      onTap: () => _openExplorer(tx.hash),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromARGB(255, 200, 200, 200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${isIncoming ? '+' : '-'}$amount $symbol',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: PlasmaTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isIncoming ? inBadgeGreen : badgeGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isIncoming ? 'IN' : 'OUT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isIncoming
                          ? inTextGreen
                          : PlasmaTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getRelativeTime(tx.timeStamp),
                  style: const TextStyle(
                    color: PlasmaTheme.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAddressRow(
              label: displayLabel,
              value: displayAddress,
              color: addressTeal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: PlasmaTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _truncate(value),
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
          },
          child: const Icon(
            Icons.copy_all_outlined,
            size: 18,
            color: Color(0xFFD0D5DD),
          ),
        ),
      ],
    );
  }

  String _truncate(String value) {
    if (value.length <= 16) return value;
    return '${value.substring(0, 10)}... ${value.substring(value.length - 1)}';
  }

  String _formatTokenAmount(BigInt value, int decimals) {
    if (value == BigInt.zero) return '0';
    final divisor = BigInt.from(10).pow(decimals);
    final whole = value ~/ divisor;
    final fraction = (value % divisor).toString().padLeft(decimals, '0');
    final trimmedFraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    return trimmedFraction.isEmpty ? '$whole' : '$whole.$trimmedFraction';
  }
}
