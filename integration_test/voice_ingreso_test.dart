// integration_test/voice_ingreso_test.dart
//
// E2E test: Create an ingreso using voice-simulated input.
//
// Flow: Home → tap FAB → AddMovementPage → select Ingreso type → enter amount → save → verify on home.
//
// Note: Native speech-to-text is not available in CI emulators.
// Instead, we fill the form directly (simulating voice-parsed result).
// This approach tests the full movement creation pipeline without voice.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart'
    show find, expect, findsOneWidget, Finder;
import 'package:patrol/patrol.dart';
import 'package:todoaldia/core/router/app_router.dart';
import 'package:todoaldia/data/database/app_database.dart';
import 'package:todoaldia/data/repositories/repository_impl.dart';
import 'package:todoaldia/domain/repositories/repositories.dart';
import 'package:todoaldia/presentation/bloc/budget/budget_bloc.dart';
import 'package:todoaldia/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:todoaldia/presentation/bloc/goal/goal_bloc.dart';
import 'package:todoaldia/presentation/bloc/home/home_bloc.dart';
import 'package:todoaldia/presentation/bloc/movement/movement_bloc.dart';

Finder valueKey(String key) => find.byKey(ValueKey(key));

/// Builds the full app with all providers and GoRouter.
Widget buildTestApp() {
  final database = AppDatabase.instance;
  final accountRepo = AccountRepositoryImpl(database);
  final categoryRepo = CategoryRepositoryImpl(database);
  final movementRepo = MovementRepositoryImpl(database);
  final budgetRepo = BudgetRepositoryImpl(database);
  final goalRepo = GoalRepositoryImpl(database);

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<AccountRepository>.value(value: accountRepo),
      RepositoryProvider<CategoryRepository>.value(value: categoryRepo),
      RepositoryProvider<MovementRepository>.value(value: movementRepo),
      RepositoryProvider<BudgetRepository>.value(value: budgetRepo),
      RepositoryProvider<GoalRepository>.value(value: goalRepo),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(
            movementRepository: movementRepo,
            categoryRepository: categoryRepo,
          ),
        ),
        BlocProvider(
          create: (context) => DashboardBloc(
            movementRepository: movementRepo,
            categoryRepository: categoryRepo,
            goalRepository: goalRepo,
          ),
        ),
        BlocProvider(
          create: (context) => MovementBloc(
            movementRepository: movementRepo,
            categoryRepository: categoryRepo,
          ),
        ),
        BlocProvider(
          create: (context) => BudgetBloc(
            budgetRepository: budgetRepo,
            movementRepository: movementRepo,
            categoryRepository: categoryRepo,
          ),
        ),
        BlocProvider(
          create: (context) => GoalBloc(
            goalRepository: goalRepo,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'TodoAlDía Test',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    ),
  );
}

void main() {
  patrolTest(
    'create ingreso via form (voice-simulated) and verify on home',
    ($) async {
      // Navigate to add movement page directly
      appRouter.go('/add');
      await $.pumpWidgetAndSettle(buildTestApp());

      // Verify add movement page loaded
      expect($(valueKey('add_save_button')), findsOneWidget);

      // Select "Ingreso" type
      await $.tap(find.text('Ingreso'));
      await $.pumpAndSettle();

      // Fill amount field (first TextFormField)
      final amountField = find.byType(TextFormField).first;
      await $.enterText(amountField, '500.00');
      await $.pumpAndSettle();

      // Save the ingreso
      await $.tap(valueKey('add_save_button'));
      await $.pumpAndSettle();

      // Should be back on home screen
      expect($(valueKey('home_fab')), findsOneWidget);
    },
  );

  patrolTest(
    'create ingreso with note and verify on home',
    ($) async {
      appRouter.go('/add');
      await $.pumpWidgetAndSettle(buildTestApp());

      // Select "Ingreso" type
      await $.tap(find.text('Ingreso'));
      await $.pumpAndSettle();

      // Amount
      final amountField = find.byType(TextFormField).first;
      await $.enterText(amountField, '1200.00');
      await $.pumpAndSettle();

      // Note (last TextFormField - after amount and category)
      final noteField = find.byType(TextFormField).last;
      await $.enterText(noteField, 'Nómina mensual');
      await $.pumpAndSettle();

      // Save
      await $.tap(valueKey('add_save_button'));
      await $.pumpAndSettle();

      // Verify back on home
      expect($(valueKey('home_fab')), findsOneWidget);
    },
  );
}
