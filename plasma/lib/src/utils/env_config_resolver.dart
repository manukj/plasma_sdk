import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfigResolver {
  static Future<String> resolveEtherscanApiKey({
    required String envFile,
    String? overrideKey,
  }) async {
    final directKey = overrideKey?.trim() ?? '';
    if (directKey.isNotEmpty) return directKey;

    try {
      await dotenv.load(fileName: envFile);
    } catch (_) {
      throw StateError(
        'Unable to load $envFile. Add ETHERSCANAPI to your .env file or pass etherscanApiKey to Plasma.init().',
      );
    }

    final envKey = dotenv.get('ETHERSCANAPI', fallback: '').trim();
    if (envKey.isEmpty) {
      throw StateError(
        'Missing ETHERSCANAPI in $envFile. Add it or pass etherscanApiKey to Plasma.init().',
      );
    }
    return envKey;
  }
}
