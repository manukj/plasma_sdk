import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plasma/plasma.dart';

import 'firebase_options.dart';
import 'widgets/plasma_genui_overview.dart';
import 'widgets/plasma_sdk_integration_overview.dart';
import 'widgets/plasma_ui_overview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: "Plasma Example App",
  );

  await Plasma.instance.init(network: Network.testnet);

  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PlasmaTheme.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: PlasmaTheme.primary,
          secondary: PlasmaTheme.primary,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: PlasmaTheme.textPrimary,
          surfaceTintColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: PlasmaTheme.primary.withValues(alpha: 0.14),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const PlasmaExampleApp(),
    ),
  );
}

class PlasmaExampleApp extends StatefulWidget {
  const PlasmaExampleApp({super.key});

  @override
  State<PlasmaExampleApp> createState() => _PlasmaExampleAppState();
}

class _PlasmaExampleAppState extends State<PlasmaExampleApp> {
  static const _pageTitles = <String>[
    'Plasma SDK',
    'Plasma UI Catalog',
    'Plasma GenUI',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const PlasmaSdkIntegrationOverview(),
      const PlasmaUiOverview(),
      const PlasmaGenUiOverview(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() => _currentIndex = value);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.code), label: 'SDK'),
          NavigationDestination(icon: Icon(Icons.widgets), label: 'UI'),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'GenUI',
          ),
        ],
      ),
    );
  }
}
