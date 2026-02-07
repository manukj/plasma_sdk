class CryptoUtils {
  static String normalizePrivateKey(String privateKey) {
    final trimmed = privateKey.trim();
    final hexBody = trimmed.startsWith('0x') || trimmed.startsWith('0X')
        ? trimmed.substring(2)
        : trimmed;

    if (hexBody.isEmpty || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexBody)) {
      throw const FormatException('Private key must be a valid hex string');
    }

    if (hexBody.length > 64) {
      throw const FormatException(
        'Private key must be 32 bytes (64 hex chars)',
      );
    }

    return '0x${hexBody.padLeft(64, '0').toLowerCase()}';
  }
}
