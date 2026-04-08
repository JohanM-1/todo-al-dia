// lib/presentation/bloc/dashboard/dashboard_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final double totalBalance;
  final double monthIncome;
  final double monthExpenses;
  final double monthSavings;
  final Map<int, double> incomeByCategory;
  final Map<int, double> expensesByCategory;
  final Map<int, int> categoryUsageCount;
  final List<MovementEntity> recentMovements;
  final List<CategoryEntity> categories;
  final int currentMonth;
  final int currentYear;
  // New fields for goals and insights
  final List<GoalEntity> topGoals;
  final double totalGoalsSaved;
  final List<CategoryEntity> topExpenseCategories;
  final double savingsRate;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.totalBalance = 0,
    this.monthIncome = 0,
    this.monthExpenses = 0,
    this.monthSavings = 0,
    this.incomeByCategory = const {},
    this.expensesByCategory = const {},
    this.categoryUsageCount = const {},
    this.recentMovements = const [],
    this.categories = const [],
    this.currentMonth = 0,
    this.currentYear = 0,
    this.topGoals = const [],
    this.totalGoalsSaved = 0,
    this.topExpenseCategories = const [],
    this.savingsRate = 0,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    double? totalBalance,
    double? monthIncome,
    double? monthExpenses,
    double? monthSavings,
    Map<int, double>? incomeByCategory,
    Map<int, double>? expensesByCategory,
    Map<int, int>? categoryUsageCount,
    List<MovementEntity>? recentMovements,
    List<CategoryEntity>? categories,
    int? currentMonth,
    int? currentYear,
    List<GoalEntity>? topGoals,
    double? totalGoalsSaved,
    List<CategoryEntity>? topExpenseCategories,
    double? savingsRate,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      totalBalance: totalBalance ?? this.totalBalance,
      monthIncome: monthIncome ?? this.monthIncome,
      monthExpenses: monthExpenses ?? this.monthExpenses,
      monthSavings: monthSavings ?? this.monthSavings,
      incomeByCategory: incomeByCategory ?? this.incomeByCategory,
      expensesByCategory: expensesByCategory ?? this.expensesByCategory,
      categoryUsageCount: categoryUsageCount ?? this.categoryUsageCount,
      recentMovements: recentMovements ?? this.recentMovements,
      categories: categories ?? this.categories,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      topGoals: topGoals ?? this.topGoals,
      totalGoalsSaved: totalGoalsSaved ?? this.totalGoalsSaved,
      topExpenseCategories: topExpenseCategories ?? this.topExpenseCategories,
      savingsRate: savingsRate ?? this.savingsRate,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        totalBalance,
        monthIncome,
        monthExpenses,
        monthSavings,
        incomeByCategory,
        expensesByCategory,
        categoryUsageCount,
        recentMovements,
        categories,
        currentMonth,
        currentYear,
        topGoals,
        totalGoalsSaved,
        topExpenseCategories,
        savingsRate,
        error,
      ];
}
