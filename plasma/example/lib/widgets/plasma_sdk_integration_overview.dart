import 'package:flutter/material.dart';

class PlasmaSdkIntegrationOverview extends StatelessWidget {
  const PlasmaSdkIntegrationOverview({super.key});

  static const String _initSnippet = '''
import 'package:plasma/plasma.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Plasma.instance.init(
    network: Network.testnet,
  );

  runApp(const MyApp());
}
''';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SDK Initialization',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This is all you need to integrate Plasma SDK in app startup.',
                  ),
                  SizedBox(height: 12),
                  _CodeBlock(text: _initSnippet),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features Provided',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 12),
                  _FeatureSection(
                    title: 'Wallet',
                    apis: [
                      'createWallet()',
                      'deleteWallet()',
                    ],
                  ),
                  _FeatureSection(
                    title: 'Account',
                    apis: [
                      'getStableTokenBalance()',
                      'getGasTokenBalance()',
                    ],
                  ),
                  _FeatureSection(
                    title: 'Transactions',
                    apis: [
                      'getTokenTransactions(number)',
                      'sendUSDT(to: ..., amount: ...)',
                    ],
                  ),
                  _FeatureSection(
                    title: 'Runtime State',
                    apis: [
                      'network',
                      'config',
                      'hasWallet',
                      'address',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0D7DE)),
      ),
      child: SelectableText(
        text.trim(),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.5,
          height: 1.35,
        ),
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({
    required this.title,
    required this.apis,
  });

  final String title;
  final List<String> apis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...apis.map(
            (api) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '- $api',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
