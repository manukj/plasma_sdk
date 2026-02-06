import 'package:flutter_test/flutter_test.dart';
import 'package:plasma/plasma.dart';

void main() {
  test('PlasmaSDK initializes', () {
    final sdk = PlasmaSDK();
    expect(sdk, isNotNull);
  });
}
