// integration_test/app.dart
// Test app setup with isolated Hive reset per test.
//
// This file provides a buildTestApp() function that creates a fresh
// Flutter app with Hive reset, suitable for E2E testing with Patrol.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoaldia/data/database/app_database.dart';
import 'package:todoaldia/data/repositories/repository_impl.dart';
import 'package:todoaldia/domain/repositories/repositories.dart';
import 'package:todoaldia/presentation/bloc/budget/budget_bloc.dart';
import 'package:todoaldia/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:todoaldia/presentation/bloc/goal/goal_bloc.dart';
import 'package:todoaldia/presentation/bloc/home/home_bloc.dart';
import 'package:todoaldia/presentation/bloc/movement/movement_bloc.dart';

/// Builds a fresh test app with Hive reset and default repositories.
/// Each test should call this once at the start.
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
      child: MaterialApp(
        title: 'TodoAlDía Test',
        home: const Scaffold(
          body: Center(child: Text('Test App')),
        ),
      ),
    ),
  );
}

/// Resets Hive database between tests for isolation.
Future<void> resetHiveForTest() async {
  await Hive.deleteFromDisk();
  // Re-initialize the database after deletion.
  // The next call to AppDatabase.instance will re-init with fresh boxes.
}
