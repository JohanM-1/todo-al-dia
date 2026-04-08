// lib/core/utils/currency_formatter.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants/currency_catalog.dart';

/// Utilidades para formatear y parsear montos según la moneda.
/// Maneja diferentes locales, separadores de miles y decimales.
class CurrencyFormatter {
  /// Formatea un monto según la moneda seleccionada.
  /// Ejemplos:
  /// - ARS (2 decimales): $1.234,56
  /// - CLP (0 decimales): $1.234.567
  /// - COP (0 decimales): $1.234.567
  /// - USD: US$1,234.56
  static String format(double amount, String currencyCode) {
    final currency = CurrencyCatalog.getByCode(currencyCode);
    if (currency == null) {
      return amount.toStringAsFixed(2);
    }

    final locale = currency.locale;
    final decimals = currency.decimalDigits;

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currency.symbol,
      decimalDigits: decimals,
    );

    return formatter.format(amount);
  }

  /// Formatea un monto con símbolo personalizado (para cuando se muestra en UI).
  /// Versión simplificada que permite control más granular.
  static String formatWithSymbol(
    double amount,
    String currencyCode, {
    bool showSymbol = true,
  }) {
    final currency = CurrencyCatalog.getByCode(currencyCode);
    if (currency == null) {
      return amount.toStringAsFixed(2);
    }

    final locale = currency.locale;
    final decimals = currency.decimalDigits;
    final symbol = currency.symbol;

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: showSymbol ? symbol : '',
      decimalDigits: decimals,
    );

    return formatter.format(amount);
  }

  /// Formatea solo el número (sin símbolo) con separadores de miles correctos.
  static String formatNumber(double amount, String currencyCode) {
    final currency = CurrencyCatalog.getByCode(currencyCode);
    if (currency == null) {
      return amount.toStringAsFixed(2);
    }

    final locale = currency.locale;
    final decimals = currency.decimalDigits;

    final formatter = NumberFormat.decimalPattern(locale);
    if (decimals > 0) {
      return formatter.format(_roundToDecimals(amount, decimals));
    }
    return formatter.format(amount.roundToDouble());
  }

  /// Parsea un string de monto al valor numérico correcto.
  /// Maneja diferentes formatos regionales:
  /// - 1.234,56 (España/Latam)
  /// - 1,234.56 (US/UK)
  /// - 1234 (CLP/COP sin decimales)
  static double? parse(String value, String currencyCode) {
    if (value.isEmpty) return null;

    final currency = CurrencyCatalog.getByCode(currencyCode);
    final locale = currency?.locale ?? 'en_US';

    // Limpiar el string: remover símbolo de moneda y espacios
    String cleaned = value.trim();

    // Remover símbolo de moneda si está presente
    if (currency != null) {
      cleaned = cleaned.replaceAll(currency.symbol, '');
    }

    // Remover todos los espacios
    cleaned = cleaned.trim();

    if (cleaned.isEmpty) return null;

    // Detectar el formato basándose en el locale
    final decimalSeparator = _getDecimalSeparator(locale);
    final groupSeparator = _getGroupSeparator(locale);

    // Normalizar:统一 separadores para parsing
    // Primero, remover separadores de miles
    cleaned = cleaned.replaceAll(groupSeparator, '');
    // Luego, cambiar separador decimal a punto
    cleaned = cleaned.replaceAll(decimalSeparator, '.');

    return double.tryParse(cleaned);
  }

  /// Parser seguro que retorna 0 en vez de null si falla.
  static double parseOrZero(String value, String currencyCode) {
    return parse(value, currencyCode) ?? 0.0;
  }

  /// Obtiene el separador decimal para un locale.
  static String _getDecimalSeparator(String locale) {
    final formatter = NumberFormat.decimalPattern(locale);
    final sample = formatter.format(1.1);
    return sample.contains(',') ? ',' : '.';
  }

  /// Obtiene el separador de miles para un locale.
  static String _getGroupSeparator(String locale) {
    final formatter = NumberFormat.decimalPattern(locale);
    final sample = formatter.format(1111);
    if (sample.contains(',') && sample.contains('.')) {
      return sample.contains('.') ? '.' : ',';
    }
    // Default para el locale
    if (locale.startsWith('es') || locale.startsWith('pt')) {
      return '.';
    }
    return ',';
  }

  /// Redondea a la cantidad de decimales apropiada.
  static double _roundToDecimals(double value, int decimals) {
    final factor = _pow10(decimals);
    return (value * factor).round() / factor;
  }

  static double _pow10(int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }
}

/// Input formatter para campos de monto en tiempo real.
/// Aplica separadores de miles mientras el usuario escribe.
/// Maneja correctamente separadores decimales según el locale de la moneda.
class CurrencyInputFormatter extends TextInputFormatter {
  final String currencyCode;

  CurrencyInputFormatter({required this.currencyCode});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final currency = CurrencyCatalog.getByCode(currencyCode);
    final locale = currency?.locale ?? 'en_US';
    final decimals = currency?.decimalDigits ?? 2;
    final decimalSep = _getDecimalSeparator(locale);
    final groupSep = _getGroupSeparator(locale);

    final formatted = _formatInput(
      newValue.text,
      decimals: decimals,
      decimalSep: decimalSep,
      groupSep: groupSep,
    );

    if (formatted.isEmpty) {
      return const TextEditingValue(text: '');
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatInput(
    String rawInput, {
    required int decimals,
    required String decimalSep,
    required String groupSep,
  }) {
    var sanitized = rawInput.replaceAll(RegExp(r'\s'), '');
    sanitized = sanitized.replaceAll(groupSep, '');

    final alternateDecimalSep = decimalSep == ',' ? '.' : ',';
    final allowAlternateDecimal =
        decimals > 0 && alternateDecimalSep != groupSep;

    sanitized = sanitized.replaceAll(
      RegExp(
        allowAlternateDecimal
            ? '[^\\d${RegExp.escape(decimalSep)}${RegExp.escape(alternateDecimalSep)}]'
            : '[^\\d${RegExp.escape(decimalSep)}]',
      ),
      '',
    );

    if (allowAlternateDecimal) {
      sanitized = sanitized.replaceAll(alternateDecimalSep, decimalSep);
    }

    if (sanitized.isEmpty) {
      return '';
    }

    if (decimals == 0) {
      final integerDigits = sanitized.replaceAll(RegExp(r'\D'), '');
      if (integerDigits.isEmpty) {
        return '';
      }
      return _addGroupSeparators(integerDigits, groupSep);
    }

    final firstDecimalIndex = sanitized.indexOf(decimalSep);
    final hasDecimalSeparator = firstDecimalIndex >= 0;

    String integerDigits;
    String decimalDigits = '';

    if (hasDecimalSeparator) {
      integerDigits = sanitized
          .substring(0, firstDecimalIndex)
          .replaceAll(RegExp(r'\D'), '');
      decimalDigits = sanitized
          .substring(firstDecimalIndex + decimalSep.length)
          .replaceAll(RegExp(r'\D'), '');
      if (decimalDigits.length > decimals) {
        decimalDigits = decimalDigits.substring(0, decimals);
      }
    } else {
      integerDigits = sanitized.replaceAll(RegExp(r'\D'), '');
    }

    if (integerDigits.isEmpty) {
      integerDigits = '0';
    }

    final formattedInteger = _addGroupSeparators(integerDigits, groupSep);

    if (!hasDecimalSeparator) {
      return formattedInteger;
    }

    return '$formattedInteger$decimalSep$decimalDigits';
  }

  String _addGroupSeparators(String digits, String groupSep) {
    final buffer = StringBuffer();
    final intLen = digits.length;
    for (int i = 0; i < intLen; i++) {
      if (i > 0 && (intLen - i) % 3 == 0) {
        buffer.write(groupSep);
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  String _getDecimalSeparator(String locale) {
    final formatter = NumberFormat.decimalPattern(locale);
    final sample = formatter.format(1.1);
    return sample.contains(',') ? ',' : '.';
  }

  String _getGroupSeparator(String locale) {
    final formatter = NumberFormat.decimalPattern(locale);
    final sample = formatter.format(1111);
    if (sample.contains(',') && sample.contains('.')) {
      return sample.contains('.') ? '.' : ',';
    }
    if (locale.startsWith('es') || locale.startsWith('pt')) {
      return '.';
    }
    return ',';
  }
}

/// Extensión удобная para formatear doubles como moneda.
extension CurrencyDisplay on double {
  /// Formatea este monto con la moneda por defecto (ARS).
  String toCurrency() {
    return CurrencyFormatter.formatWithSymbol(this, 'ARS');
  }

  /// Formatea este monto con la moneda especificada.
  String toCurrencyCode(String code) {
    return CurrencyFormatter.formatWithSymbol(this, code);
  }

  /// Formatea este monto con la moneda y opcionalmente sin símbolo.
  String toCurrencyWith(String code, {bool showSymbol = true}) {
    return CurrencyFormatter.formatWithSymbol(this, code,
        showSymbol: showSymbol);
  }
}
