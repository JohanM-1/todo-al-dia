// lib/presentation/bloc/budget/budget_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

enum BudgetAlertLevel { normal, warning, exceeded }

class BudgetWithProgress extends Equatable {
  final BudgetEntity budget;
  final double spent;
  final double remaining;
  final double percentage;
  final BudgetAlertLevel level;
  final CategoryEntity? category;

  const BudgetWithProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.level,
    this.category,
  });

  @override
  List<Object?> get props =>
      [budget, spent, remaining, percentage, level, category];
}

class BudgetAlert extends Equatable {
  final BudgetEntity budget;
  final double spent;
  final double percentage;
  final BudgetAlertLevel level;

  const BudgetAlert({
    required this.budget,
    required this.spent,
    required this.percentage,
    required this.level,
  });

  @override
  List<Object?> get props => [budget, spent, percentage, level];
}

class BudgetState extends Equatable {
  final bool isLoading;
  final List<BudgetEntity> budgets;
  final List<BudgetWithProgress> budgetsWithProgress;
  final List<BudgetAlert> alerts;
  final int? currentMonth;
  final int? currentYear;
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final String? error;
  final String? successMessage;

  const BudgetState({
    this.isLoading = false,
    this.budgets = const [],
    this.budgetsWithProgress = const [],
    this.alerts = const [],
    this.currentMonth,
    this.currentYear,
    this.totalBudget = 0,
    this.totalSpent = 0,
    this.totalRemaining = 0,
    this.error,
    this.successMessage,
  });

  BudgetState copyWith({
    bool? isLoading,
    List<BudgetEntity>? budgets,
    List<BudgetWithProgress>? budgetsWithProgress,
    List<BudgetAlert>? alerts,
    int? currentMonth,
    int? currentYear,
    double? totalBudget,
    double? totalSpent,
    double? totalRemaining,
    String? error,
    String? successMessage,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      budgets: budgets ?? this.budgets,
      budgetsWithProgress: budgetsWithProgress ?? this.budgetsWithProgress,
      alerts: alerts ?? this.alerts,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      totalRemaining: totalRemaining ?? this.totalRemaining,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        budgets,
        budgetsWithProgress,
        alerts,
        currentMonth,
        currentYear,
        totalBudget,
        totalSpent,
        totalRemaining,
        error,
        successMessage
      ];
}
