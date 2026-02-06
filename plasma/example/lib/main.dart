import 'package:flutter/material.dart';
import 'package:plasma/plasma.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plasma SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PlasmaSDK _plasmaSDK = PlasmaSDK();
  String _displayText = 'Initializing Plasma SDK...';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlasma();
  }

  Future<void> _initializePlasma() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _displayText = 'Initializing Plasma SDK...';
      });

      // Initialize the SDK
      await _plasmaSDK.initialize();

      setState(() {
        _displayText = 'SDK initialized. Fetching message...';
      });

      // Give a small delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 500));

      // Call the JavaScript function
      final message = await _plasmaSDK.getHelloWorld();

      setState(() {
        _displayText = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _displayText = 'Error: $e';
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _plasmaSDK.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Plasma SDK Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _isLoading
                    ? Icons.hourglass_empty
                    : _hasError
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                size: 80,
                color: _isLoading
                    ? Colors.blue
                    : _hasError
                    ? Colors.red
                    : Colors.green,
              ),
              const SizedBox(height: 32),
              const Text(
                'Message from JavaScript:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  _displayText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _hasError ? Colors.red : Colors.black87,
                  ),
                ),
              const SizedBox(height: 32),
              if (!_isLoading)
                ElevatedButton.icon(
                  onPressed: _initializePlasma,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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
