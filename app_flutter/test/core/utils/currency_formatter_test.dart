import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoaldia/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyInputFormatter', () {
    test('formats ARS thousands without resetting at 1000', () {
      final formatter = CurrencyInputFormatter(currencyCode: 'COP');

      var value = const TextEditingValue();

      value = formatter.formatEditUpdate(
        value,
        const TextEditingValue(text: '1'),
      );
      expect(value.text, '1');

      value = formatter.formatEditUpdate(
        value,
        const TextEditingValue(text: '10'),
      );
      expect(value.text, '10');

      value = formatter.formatEditUpdate(
        value,
        const TextEditingValue(text: '100'),
      );
      expect(value.text, '100');

      value = formatter.formatEditUpdate(
        value,
        const TextEditingValue(text: '1000'),
      );
      expect(value.text, '1.000');
    });

    test('preserves locale decimal separator for ARS', () {
      final formatter = CurrencyInputFormatter(currencyCode: 'COP');

      final value = formatter.formatEditUpdate(
        const TextEditingValue(text: '1000'),
        const TextEditingValue(text: '1000,5'),
      );

      expect(value.text, '1.000,5');
    });

    test('formats COP without decimals', () {
      final formatter = CurrencyInputFormatter(currencyCode: 'COP');

      final value = formatter.formatEditUpdate(
        const TextEditingValue(text: '100'),
        const TextEditingValue(text: '1000'),
      );

      expect(value.text, '1.000');
    });
  });
}
