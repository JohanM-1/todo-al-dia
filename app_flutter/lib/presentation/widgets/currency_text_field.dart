// lib/presentation/widgets/currency_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/currency_catalog.dart';
import '../../core/utils/currency_formatter.dart';

/// TextField especializado para ingreso de montos.
/// Aplica formato de moneda mientras el usuario escribe.
///
/// Uso:
/// ```dart
/// CurrencyTextField(
///   controller: _amountController,
///   currencyCode: 'COP', // o 'ARS', 'CLP', etc.
///   labelText: 'Monto',
/// )
/// ```
class CurrencyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String currencyCode;
  final String? labelText;
  final String? hintText;
  final String? prefixText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const CurrencyTextField({
    super.key,
    required this.controller,
    required this.currencyCode,
    this.labelText,
    this.hintText,
    this.prefixText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Get symbol for prefix
    final symbol = CurrencyCatalog.getSymbol(currencyCode);

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        CurrencyInputFormatter(currencyCode: currencyCode),
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? _getHint(currencyCode),
        prefixText: prefixText ?? '$symbol ',
      ),
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
    );
  }

  String _getHint(String code) {
    final currency = CurrencyCatalog.getByCode(code);
    if (currency == null) return '0.00';

    if (currency.decimalDigits == 0) {
      return 'Ej: 1000000';
    }
    return 'Ej: 1${_getGroupSeparator(currency.locale)}000${_getDecimalSeparator(currency.locale)}00';
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

  String _getDecimalSeparator(String locale) {
    final formatter = NumberFormat.decimalPattern(locale);
    final sample = formatter.format(1.1);
    return sample.contains(',') ? ',' : '.';
  }
}

/// Helper mixin para widgets que necesitan acceso a la moneda.
/// Provee método getCurrentCurrency().
mixin CurrencyAwareWidget<T extends StatefulWidget> on State<T> {
  String get currentCurrency => 'COP';

  /// Parsea el valor del controller usando la moneda actual.
  double parseAmount(TextEditingController controller) {
    return CurrencyFormatter.parseOrZero(
      controller.text,
      currentCurrency,
    );
  }
}
