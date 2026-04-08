// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'TodoAlDía';
  static const String appVersion = '0.1.0';

  // Default values
  static const String defaultCurrency = 'ARS';
  static const String defaultAccount = 'Efectivo';

  // Voice
  static const int voiceTimeoutSeconds = 30;
  static const double minConfidence = 0.7;

  // Voice Intent Patterns
  static const List<String> expensePatterns = [
    'gasté',
    'gaste',
    'pagué',
    'pague',
    'compré',
    'compre',
    'débito',
    'crédito',
    'efectivo',
    'tarjeta',
  ];

  static const List<String> incomePatterns = [
    'cobré',
    'cobre',
    'recibí',
    'recibí',
    'me pagaron',
    'ingresé',
    'transferencia',
    'depósito',
    'salario',
    'freelance',
  ];

  static const List<String> balanceQueryPatterns = [
    'cuánto tengo',
    'cuanto tengo',
    'balance',
    'cuánto me queda',
    'cuanto me queda',
    'cómo voy',
    'como voy',
  ];

  static const List<String> spendingQueryPatterns = [
    'cuánto gasté',
    'cuanto gasté',
    'en qué gasté',
    'en que gasté',
    'gastos de',
    'gastado en',
  ];

  // Default Categories
  static const List<String> defaultExpenseCategories = [
    'Comida',
    'Supermercado',
    'Transporte',
    'Casa',
    'Entretenimiento',
    'Salud',
    'Ropa',
    'Servicios',
    'Regalos',
    'Otros',
  ];

  static const List<String> defaultIncomeCategories = [
    'Salario',
    'Freelance',
    'Inversión',
    'Regalo',
    'Otro',
  ];

  // Default merchants/payment methods
  static const List<String> paymentMethods = [
    'efectivo',
    'débito',
    'crédito',
    'transferencia',
  ];

  // Budget alerts
  static const double budgetWarningThreshold = 0.8;
  static const double budgetCriticalThreshold = 1.0;

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String monthFormat = 'MMMM yyyy';
}
