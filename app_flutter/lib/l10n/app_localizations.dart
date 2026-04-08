import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TodoAlDía'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Movements tab label
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get movements;

  /// Budgets tab label
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Goals tab label
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Income label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense label
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Savings label
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// Recent movements section title
  ///
  /// In en, this message translates to:
  /// **'Recent Movements'**
  String get recentMovements;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No movements yet'**
  String get noMovements;

  /// Empty state hint
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to register your first expense'**
  String get tapPlusToStart;

  /// Add movement page title
  ///
  /// In en, this message translates to:
  /// **'Add Movement'**
  String get addMovement;

  /// Edit movement page title
  ///
  /// In en, this message translates to:
  /// **'Edit Movement'**
  String get editMovement;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Delete movement title
  ///
  /// In en, this message translates to:
  /// **'Delete Movement'**
  String get deleteMovement;

  /// Delete movement confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this movement?'**
  String get deleteMovementConfirm;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// General settings section
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Data settings section
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// About settings section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Currency setting label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Theme color setting label
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Categories setting label
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Manage categories setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// Export setting label
  ///
  /// In en, this message translates to:
  /// **'Export Movements'**
  String get exportMovements;

  /// Export setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCSV;

  /// Delete data setting label
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// Delete data setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Delete all history'**
  String get deleteAllDataSubtitle;

  /// Version setting label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Terms setting label
  ///
  /// In en, this message translates to:
  /// **'Terms and Privacy'**
  String get termsAndPrivacy;

  /// Currency picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// Theme picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// Color picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// Language picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Auto language option
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Delete data confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteDataConfirm;

  /// Delete data warning message
  ///
  /// In en, this message translates to:
  /// **'This will delete all movements, budgets, and goals. This action cannot be undone.'**
  String get deleteDataWarning;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message prefix
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Data deleted snackbar message
  ///
  /// In en, this message translates to:
  /// **'Data deleted'**
  String get dataDeleted;

  /// Monthly summary section title
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummary;

  /// Expenses by category section title
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// Default category name
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategory;

  /// Add goal page title
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// Edit goal page title
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// Goal name field label
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// Target amount field label
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// Current amount field label
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// Deadline field label
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// Add budget page title
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// Edit budget page title
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// Budget amount field label
  ///
  /// In en, this message translates to:
  /// **'Budget Amount'**
  String get budgetAmount;

  /// Spent amount label
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// Remaining amount label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Empty budgets message
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgets;

  /// Empty goals message
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoals;

  /// Budget exceeded warning
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceeded;

  /// Budget warning message
  ///
  /// In en, this message translates to:
  /// **'Budget Warning'**
  String get budgetWarning;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
