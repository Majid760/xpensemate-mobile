import 'package:flutter_test/flutter_test.dart';
import 'package:xpensemate/core/theme/colors/dark_colors.dart';

void main() {
  test('DarkColors.colorScheme should be valid', () {
    final scheme = DarkColors.colorScheme;
    expect(scheme, isNotNull);
  });
}
