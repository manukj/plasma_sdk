import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plasma_core/plasma_core.dart';

class PlasmaApi {
  static const String _apiKey = "YOUR_PLASMA_API_KEY";

  /// Sends the EIP-3009 signature payload to the Plasma relayer API.
  /// Uses the relayer URL from the provided network configuration.
  static Future<String> submitGaslessTransfer(
    Map<String, dynamic> signedData, {
    required NetworkConfig config,
  }) async {
    // Get relayer URL from network config
    final baseUrl = config.relayerUrl;
    final url = Uri.parse("$baseUrl/v1/submit");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Api-Key": _apiKey,
          "X-User-IP": "127.0.0.1",
        },
        body: jsonEncode(signedData),
      );

      // ignore: avoid_print
      print("Relayer Code: ${response.statusCode}");
      // ignore: avoid_print
      print("Relayer Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data["authorizationId"] != null) {
          return "Success! ID: ${data["authorizationId"]}";
        }
        return "Success: ${response.body}";
      }

      return "API Error: ${response.body}";
    } catch (e) {
      return "Network Error: $e";
    }
  }
}
