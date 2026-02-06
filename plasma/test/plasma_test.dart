import 'package:flutter_test/flutter_test.dart';

import 'package:plasma/plasma.dart';

void main() {
  test('Plasma SDK initializes', () {
    final plasma = Plasma.instance;
    expect(plasma, isNotNull);
  });
}
