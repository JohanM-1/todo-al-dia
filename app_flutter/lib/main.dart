// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/error/app_error_handler.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/database/app_database.dart';
import 'data/repositories/repository_impl.dart';
import 'domain/repositories/repositories.dart';
import 'l10n/app_localizations.dart';
import 'presentation/bloc/budget/budget_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/goal/goal_bloc.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/movement/movement_bloc.dart';
import 'presentation/bloc/settings/settings_bloc.dart';
import 'presentation/bloc/settings/settings_event.dart';
import 'presentation/bloc/settings/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  final database = AppDatabase.instance;
  await database.initialize();

  // Initialize repositories
  final accountRepo = AccountRepositoryImpl(database);
  final categoryRepo = CategoryRepositoryImpl(database);
  final movementRepo = MovementRepositoryImpl(database);
  final budgetRepo = BudgetRepositoryImpl(database);
  final goalRepo = GoalRepositoryImpl(database);

  runApp(TodoAlDiaApp(
    accountRepository: accountRepo,
    categoryRepository: categoryRepo,
    movementRepository: movementRepo,
    budgetRepository: budgetRepo,
    goalRepository: goalRepo,
    database: database,
  ));
}

class TodoAlDiaApp extends StatelessWidget {
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final MovementRepository movementRepository;
  final BudgetRepository budgetRepository;
  final GoalRepository goalRepository;
  final AppDatabase database;

  const TodoAlDiaApp({
    super.key,
    required this.accountRepository,
    required this.categoryRepository,
    required this.movementRepository,
    required this.budgetRepository,
    required this.goalRepository,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AccountRepository>.value(value: accountRepository),
        RepositoryProvider<CategoryRepository>.value(value: categoryRepository),
        RepositoryProvider<MovementRepository>.value(value: movementRepository),
        RepositoryProvider<BudgetRepository>.value(value: budgetRepository),
        RepositoryProvider<GoalRepository>.value(value: goalRepository),
        RepositoryProvider<AppDatabase>.value(value: database),
      ],
      child: BlocProvider(
        create: (context) => SettingsBloc(db: database)..add(LoadSettings()),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (previous, current) =>
              previous.themeColor != current.themeColor ||
              previous.themeMode != current.themeMode ||
              previous.languageCode != current.languageCode,
          builder: (context, settingsState) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => HomeBloc(
                    movementRepository: movementRepository,
                    categoryRepository: categoryRepository,
                  ),
                ),
                BlocProvider(
                  create: (context) => DashboardBloc(
                    movementRepository: movementRepository,
                    categoryRepository: categoryRepository,
                    goalRepository: goalRepository,
                  ),
                ),
                BlocProvider(
                  create: (context) => MovementBloc(
                    movementRepository: movementRepository,
                    categoryRepository: categoryRepository,
                  ),
                ),
                BlocProvider(
                  create: (context) => BudgetBloc(
                    budgetRepository: budgetRepository,
                    movementRepository: movementRepository,
                    categoryRepository: categoryRepository,
                  ),
                ),
                BlocProvider(
                  create: (context) => GoalBloc(
                    goalRepository: goalRepository,
                  ),
                ),
              ],
              child: _AppContent(
                accountRepository: accountRepository,
                categoryRepository: categoryRepository,
                movementRepository: movementRepository,
                budgetRepository: budgetRepository,
                goalRepository: goalRepository,
                settingsState: settingsState,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppContent extends StatelessWidget {
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final MovementRepository movementRepository;
  final BudgetRepository budgetRepository;
  final GoalRepository goalRepository;
  final SettingsState settingsState;

  const _AppContent({
    required this.accountRepository,
    required this.categoryRepository,
    required this.movementRepository,
    required this.budgetRepository,
    required this.goalRepository,
    required this.settingsState,
  });

  @override
  Widget build(BuildContext context) {
    // Determine locale based on settings
    Locale? locale;
    if (settingsState.languageCode != null &&
        settingsState.languageCode!.isNotEmpty) {
      locale = Locale(settingsState.languageCode!);
    }

    return MaterialApp.router(
      title: 'TodoAlDía',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(primaryColor: settingsState.themeColor),
      darkTheme: AppTheme.dark(primaryColor: settingsState.themeColor),
      themeMode: settingsState.themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: appRouter,
      // Global error widget for uncaught exceptions
      builder: (context, child) {
        ErrorWidget.builder = (details) {
          return AppErrorHandler.buildErrorWidget(details);
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
