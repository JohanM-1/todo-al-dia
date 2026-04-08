// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TodoAlDía';

  @override
  String get home => 'Inicio';

  @override
  String get movements => 'Movimientos';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get goals => 'Metas';

  @override
  String get settings => 'Ajustes';

  @override
  String get balance => 'Saldo';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get savings => 'Ahorro';

  @override
  String get recentMovements => 'Movimientos Recientes';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get noMovements => 'No hay movimientos aún';

  @override
  String get tapPlusToStart => 'Toca el botón + para registrar tu primer gasto';

  @override
  String get addMovement => 'Agregar Movimiento';

  @override
  String get editMovement => 'Editar Movimiento';

  @override
  String get amount => 'Monto';

  @override
  String get description => 'Descripción';

  @override
  String get category => 'Categoría';

  @override
  String get date => 'Fecha';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteMovement => 'Eliminar Movimiento';

  @override
  String get deleteMovementConfirm =>
      '¿Estás seguro de que quieres eliminar este movimiento?';

  @override
  String get configuration => 'Configuración';

  @override
  String get general => 'General';

  @override
  String get data => 'Datos';

  @override
  String get about => 'Acerca de';

  @override
  String get currency => 'Moneda';

  @override
  String get theme => 'Tema';

  @override
  String get themeColor => 'Color del tema';

  @override
  String get language => 'Idioma';

  @override
  String get categories => 'Categorías';

  @override
  String get manageCategories => 'Gestionar categorías';

  @override
  String get exportMovements => 'Exportar movimientos';

  @override
  String get exportToCSV => 'Exportar a CSV';

  @override
  String get deleteAllData => 'Borrar todos los datos';

  @override
  String get deleteAllDataSubtitle => 'Eliminar todo el historial';

  @override
  String get version => 'Versión';

  @override
  String get termsAndPrivacy => 'Términos y privacidad';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacySubtitle => 'Cómo usa la app tus datos y permisos';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get selectColor => 'Seleccionar color';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get auto => 'Automático';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get deleteDataConfirm => '¿Borrar todos los datos?';

  @override
  String get deleteDataWarning =>
      'Esta acción eliminará todos los movimientos, presupuestos y metas. Esta acción no se puede deshacer.';

  @override
  String get retry => 'Reintentar';

  @override
  String get error => 'Error';

  @override
  String get dataDeleted => 'Datos eliminados';

  @override
  String get monthlySummary => 'Resumen Mensual';

  @override
  String get expensesByCategory => 'Gastos por Categoría';

  @override
  String get noCategory => 'Sin categoría';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get editGoal => 'Editar Meta';

  @override
  String get goalName => 'Nombre de la meta';

  @override
  String get targetAmount => 'Monto objetivo';

  @override
  String get currentAmount => 'Monto actual';

  @override
  String get deadline => 'Fecha límite';

  @override
  String get addBudget => 'Agregar Presupuesto';

  @override
  String get editBudget => 'Editar Presupuesto';

  @override
  String get budgetAmount => 'Monto del presupuesto';

  @override
  String get spent => 'Gastado';

  @override
  String get remaining => 'Restante';

  @override
  String get noBudgets => 'No hay presupuestos aún';

  @override
  String get noGoals => 'No hay metas aún';

  @override
  String get budgetExceeded => 'Presupuesto Excedido';

  @override
  String get budgetWarning => 'Advertencia de presupuesto';

  @override
  String get unavailable => 'No disponible';

  @override
  String get searchByNameOrCode => 'Buscar por nombre o código';

  @override
  String get noCurrenciesFound => 'No encontramos monedas para esa búsqueda.';

  @override
  String get settingsHeroEyebrow => 'Preferencias';

  @override
  String get settingsHeroTitle => 'Personalizá la app para tu día a día.';

  @override
  String get settingsHeroSubtitle =>
      'Tema, idioma, moneda y accesos de datos agrupados con una jerarquía visual más limpia.';

  @override
  String get shellSubtitle => 'Control diario';

  @override
  String get selectThemeColor => 'Seleccionar color';

  @override
  String privacyTitle(String appName) {
    return 'Privacidad de $appName';
  }

  @override
  String get privacyIntro =>
      'Aplicamos una política simple y poco invasiva: tu información se guarda en tu dispositivo y solo se usa para las funciones que elegís dentro de la app.';

  @override
  String get privacyLocalDataTitle => 'Datos locales';

  @override
  String get privacyLocalDataDescription =>
      'Tus movimientos, categorías y preferencias se almacenan localmente en este dispositivo.';

  @override
  String get privacyMicrophoneTitle => 'Micrófono';

  @override
  String get privacyMicrophoneDescription =>
      'Solo se solicita cuando usás funciones por voz y no forma parte del uso normal de la app.';

  @override
  String get privacyExportsTitle => 'Exportaciones';

  @override
  String get privacyExportsDescription =>
      'Los archivos se generan únicamente cuando iniciás una exportación desde configuración.';

  @override
  String get privacyNoSyncTitle => 'Sin sincronización automática';

  @override
  String get privacyNoSyncDescription =>
      'La app no muestra integración de cuenta ni sincronización en la nube desde esta pantalla.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingWelcomeEyebrow => 'Bienvenido';

  @override
  String get onboardingWelcomeTitle =>
      'Ordená tu plata con una interfaz clara.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Registrá movimientos, seguí presupuestos y convertí metas en decisiones visibles desde el primer día.';

  @override
  String get onboardingVoiceFeature => 'Voz';

  @override
  String get onboardingBudgetsFeature => 'Presupuestos';

  @override
  String get onboardingGoalsFeature => 'Metas';

  @override
  String get onboardingCurrencyTitle => '¿Cuál es tu moneda?';

  @override
  String get onboardingCurrencySubtitle =>
      'Seleccioná la moneda principal para tus transacciones.';

  @override
  String get onboardingCurrencyDefaultHint =>
      'COP queda preseleccionado como moneda inicial.';

  @override
  String get onboardingAccountTitle => 'Creá tu primera cuenta';

  @override
  String get onboardingAccountSubtitle =>
      'Una cuenta te permite organizar tus movimientos. Podés agregar más después.';

  @override
  String get accountName => 'Nombre de la cuenta';

  @override
  String get cashAccount => 'Efectivo';

  @override
  String get selectedCurrencyLabel => 'Moneda:';

  @override
  String get onboardingAccountTip =>
      'Tip: Empezá con \"Efectivo\" y podés agregar cuentas bancarias después.';

  @override
  String get back => 'Atrás';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get start => 'Comenzar';
}
