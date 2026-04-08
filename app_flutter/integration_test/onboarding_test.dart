// integration_test/onboarding_test.dart
//
// E2E test: First-time user completes onboarding flow.
//
// Flow: App launches → onboarding screens → create account → home empty state.
// The app starts at /home, but /onboarding is a separate route.
// For a fresh install, we navigate to /onboarding explicitly.
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

/// Builds a minimal test app with Hive initialized.
Widget buildTestAppWithRouter() {
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
    'first-time user completes onboarding and lands on home',
    ($) async {
      // Launch the app with the router starting at /onboarding
      appRouter.go('/onboarding');
      await $.pumpWidgetAndSettle(buildTestAppWithRouter());

      // Should see the onboarding skip button (welcome page)
      expect($(valueKey('onboarding_skip')), findsOneWidget);

      // Go through all pages and create account
      // Page 0 → 1: tap Next
      await $.tap(valueKey('onboarding_next'));
      await $.pumpAndSettle();

      // Page 1: select currency ARS (already selected by default) → tap Next
      await $.tap(valueKey('onboarding_next'));
      await $.pumpAndSettle();

      // Page 2: enter account name and create account
      await $.enterText(valueKey('onboarding_account_name'), 'Mi Cuenta');
      await $.pumpAndSettle();
      await $.tap(valueKey('onboarding_create_account'));
      await $.pumpAndSettle();

      // Should land on home screen
      expect($(valueKey('home_fab')), findsOneWidget);
      // Empty state should be visible for a fresh account
      expect($(valueKey('home_empty_state')), findsOneWidget);
    },
  );

  patrolTest(
    'user skips onboarding and creates account directly',
    ($) async {
      appRouter.go('/onboarding');
      await $.pumpWidgetAndSettle(buildTestAppWithRouter());

      // Skip onboarding
      await $.tap(valueKey('onboarding_skip'));
      await $.pumpAndSettle();

      // Should be on account creation page
      expect($(valueKey('onboarding_account_name')), findsOneWidget);

      // Enter account name and create
      await $.enterText(valueKey('onboarding_account_name'), 'Cash Account');
      await $.pumpAndSettle();
      await $.tap(valueKey('onboarding_create_account'));
      await $.pumpAndSettle();

      // Should land on home
      expect($(valueKey('home_fab')), findsOneWidget);
    },
  );
}
