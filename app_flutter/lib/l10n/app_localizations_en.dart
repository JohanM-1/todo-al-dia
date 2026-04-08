// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TodoAlDía';

  @override
  String get home => 'Home';

  @override
  String get movements => 'Movements';

  @override
  String get budgets => 'Budgets';

  @override
  String get goals => 'Goals';

  @override
  String get settings => 'Settings';

  @override
  String get balance => 'Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get savings => 'Savings';

  @override
  String get recentMovements => 'Recent Movements';

  @override
  String get viewAll => 'View All';

  @override
  String get noMovements => 'No movements yet';

  @override
  String get tapPlusToStart =>
      'Tap the + button to register your first expense';

  @override
  String get addMovement => 'Add Movement';

  @override
  String get editMovement => 'Edit Movement';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteMovement => 'Delete Movement';

  @override
  String get deleteMovementConfirm =>
      'Are you sure you want to delete this movement?';

  @override
  String get configuration => 'Configuration';

  @override
  String get general => 'General';

  @override
  String get data => 'Data';

  @override
  String get about => 'About';

  @override
  String get currency => 'Currency';

  @override
  String get theme => 'Theme';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get language => 'Language';

  @override
  String get categories => 'Categories';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get exportMovements => 'Export Movements';

  @override
  String get exportToCSV => 'Export to CSV';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteAllDataSubtitle => 'Delete all history';

  @override
  String get version => 'Version';

  @override
  String get termsAndPrivacy => 'Terms and Privacy';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySubtitle => 'How the app uses your data and permissions';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectColor => 'Select Color';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get auto => 'Auto';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get deleteDataConfirm => 'Delete all data?';

  @override
  String get deleteDataWarning =>
      'This will delete all movements, budgets, and goals. This action cannot be undone.';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get dataDeleted => 'Data deleted';

  @override
  String get monthlySummary => 'Monthly Summary';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get noCategory => 'No category';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get goalName => 'Goal Name';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get currentAmount => 'Current Amount';

  @override
  String get deadline => 'Deadline';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get noBudgets => 'No budgets yet';

  @override
  String get noGoals => 'No goals yet';

  @override
  String get budgetExceeded => 'Budget Exceeded';

  @override
  String get budgetWarning => 'Budget Warning';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get searchByNameOrCode => 'Search by name or code';

  @override
  String get noCurrenciesFound =>
      'We couldn\'t find currencies for that search.';

  @override
  String get settingsHeroEyebrow => 'Preferences';

  @override
  String get settingsHeroTitle => 'Tailor the app to your daily routine.';

  @override
  String get settingsHeroSubtitle =>
      'Theme, language, currency, and data shortcuts grouped with a cleaner visual hierarchy.';

  @override
  String get shellSubtitle => 'Daily control';

  @override
  String get selectThemeColor => 'Select color';

  @override
  String privacyTitle(String appName) {
    return '$appName Privacy';
  }

  @override
  String get privacyIntro =>
      'We apply a simple, low-friction policy: your information stays on your device and is only used for the features you choose inside the app.';

  @override
  String get privacyLocalDataTitle => 'Local data';

  @override
  String get privacyLocalDataDescription =>
      'Your movements, categories, and preferences are stored locally on this device.';

  @override
  String get privacyMicrophoneTitle => 'Microphone';

  @override
  String get privacyMicrophoneDescription =>
      'It is only requested when you use voice features and is not part of the app\'s normal usage.';

  @override
  String get privacyExportsTitle => 'Exports';

  @override
  String get privacyExportsDescription =>
      'Files are generated only when you start an export from settings.';

  @override
  String get privacyNoSyncTitle => 'No automatic sync';

  @override
  String get privacyNoSyncDescription =>
      'The app does not expose account integration or cloud sync from this screen.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingWelcomeEyebrow => 'Welcome';

  @override
  String get onboardingWelcomeTitle =>
      'Organize your money with a clear interface.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Log movements, track budgets, and turn goals into visible decisions from day one.';

  @override
  String get onboardingVoiceFeature => 'Voice';

  @override
  String get onboardingBudgetsFeature => 'Budgets';

  @override
  String get onboardingGoalsFeature => 'Goals';

  @override
  String get onboardingCurrencyTitle => 'What\'s your currency?';

  @override
  String get onboardingCurrencySubtitle =>
      'Choose the main currency for your transactions.';

  @override
  String get onboardingCurrencyDefaultHint =>
      'COP is preselected as your starting currency.';

  @override
  String get onboardingAccountTitle => 'Create your first account';

  @override
  String get onboardingAccountSubtitle =>
      'An account helps you organize your movements. You can add more later.';

  @override
  String get accountName => 'Account name';

  @override
  String get cashAccount => 'Cash';

  @override
  String get selectedCurrencyLabel => 'Currency:';

  @override
  String get onboardingAccountTip =>
      'Tip: Start with \"Cash\" and you can add bank accounts later.';

  @override
  String get back => 'Back';

  @override
  String get continueLabel => 'Continue';

  @override
  String get start => 'Start';
}
