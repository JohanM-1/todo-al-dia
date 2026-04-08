// lib/presentation/bloc/dashboard/dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final MovementRepository movementRepository;
  final CategoryRepository categoryRepository;
  final GoalRepository goalRepository;

  DashboardBloc({
    required this.movementRepository,
    required this.categoryRepository,
    required this.goalRepository,
  }) : super(const DashboardState()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LoadDashboardForMonth>(_onLoadDashboardForMonth);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    final now = DateTime.now();
    await _onLoadDashboardForMonth(
        LoadDashboardForMonth(month: now.month, year: now.year), emit);
  }

  Future<void> _onRefreshDashboard(
      RefreshDashboard event, Emitter<DashboardState> emit) async {
    add(LoadDashboardForMonth(
        month: state.currentMonth, year: state.currentYear));
  }

  Future<void> _onLoadDashboardForMonth(
      LoadDashboardForMonth event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final monthStart = DateTime(event.year, event.month);
      final monthEnd = DateTime(event.year, event.month + 1, 0);

      final results = await Future.wait([
        movementRepository.getTotalBalance(),
        movementRepository.getBalanceForPeriod(monthStart, monthEnd),
        movementRepository.getExpensesByCategory(monthStart, monthEnd),
        movementRepository.getCategoryUsageCount(monthStart, monthEnd),
        movementRepository.getAllMovements(),
        categoryRepository.getAllCategories(),
        goalRepository.getAllGoals(),
      ]);

      final totalBalance = results[0] as double;
      final expensesByCategory = results[2] as Map<int, double>;
      final categoryUsageCount = results[3] as Map<int, int>;
      final allMovements = results[4] as List<MovementEntity>;
      final categories = results[5] as List<CategoryEntity>;
      final goals = results[6] as List<GoalEntity>;

      final monthMovements = allMovements
          .where((m) =>
              m.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
              m.date.isBefore(monthEnd.add(const Duration(days: 1))))
          .toList();

      double monthIncome = 0;
      double monthExpenses = 0;
      final Map<int, double> incomeByCategory = {};

      for (final m in monthMovements) {
        if (m.type == MovementType.income) {
          monthIncome += m.amount;
          incomeByCategory[m.categoryId] =
              (incomeByCategory[m.categoryId] ?? 0) + m.amount;
        } else {
          monthExpenses += m.amount;
        }
      }

      final monthSavings = monthIncome - monthExpenses;
      final savingsRate =
          monthIncome > 0 ? (monthSavings / monthIncome) * 100.0 : 0.0;
      final recentMovements = allMovements.take(10).toList();

      // Get top goals (active, not completed)
      final activeGoals = goals.where((g) => !g.isCompleted).toList()
        ..sort((a, b) => b.progress.compareTo(a.progress));
      final topGoals = activeGoals.take(3).toList();
      final totalGoalsSaved =
          goals.fold<double>(0, (sum, g) => sum + g.currentAmount);

      // Get top expense categories by usage frequency (not amount)
      final sortedByFrequency = categoryUsageCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topCategoryIds =
          sortedByFrequency.take(3).map((e) => e.key).toList();
      final topCategories =
          categories.where((c) => topCategoryIds.contains(c.id)).toList();

      emit(state.copyWith(
        isLoading: false,
        totalBalance: totalBalance,
        monthIncome: monthIncome,
        monthExpenses: monthExpenses,
        monthSavings: monthSavings,
        incomeByCategory: incomeByCategory,
        expensesByCategory: expensesByCategory,
        categoryUsageCount: categoryUsageCount,
        recentMovements: recentMovements,
        categories: categories,
        currentMonth: event.month,
        currentYear: event.year,
        topGoals: topGoals,
        totalGoalsSaved: totalGoalsSaved,
        topExpenseCategories: topCategories,
        savingsRate: savingsRate,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
