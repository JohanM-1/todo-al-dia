// lib/presentation/bloc/budget/budget_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository budgetRepository;
  final MovementRepository movementRepository;
  final CategoryRepository categoryRepository;

  BudgetBloc({
    required this.budgetRepository,
    required this.movementRepository,
    required this.categoryRepository,
  }) : super(const BudgetState()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<LoadBudgetsForPeriod>(_onLoadBudgetsForPeriod);
    on<CreateBudget>(_onCreateBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<CalculateBudgetAlerts>(_onCalculateBudgetAlerts);
    on<MoveBudgetAmount>(_onMoveBudgetAmount);
  }

  Future<void> _onLoadBudgets(
      LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final budgets = await budgetRepository.getAllBudgets();
      emit(state.copyWith(isLoading: false, budgets: budgets));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadBudgetsForPeriod(
      LoadBudgetsForPeriod event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final budgets = await budgetRepository.getAllBudgets();
      final periodBudgets = budgets
          .where(
              (b) => b.periodMonth == event.month && b.periodYear == event.year)
          .toList();

      final categories = await categoryRepository.getAllCategories();
      final monthStart = DateTime(event.year, event.month);
      final monthEnd = DateTime(event.year, event.month + 1, 0);

      final budgetsWithProgress = await Future.wait(
        periodBudgets.map((budget) async {
          final movements = await movementRepository.getMovementsByDateRange(
              monthStart, monthEnd);
          final categoryMovements = movements.where((m) =>
              m.categoryId == budget.categoryId &&
              m.type == MovementType.expense);
          final spent =
              categoryMovements.fold<double>(0, (sum, m) => sum + m.amount);
          final remaining = (budget.limit - spent).clamp(0.0, double.infinity);
          final percentage =
              budget.limit > 0 ? (spent / budget.limit) * 100.0 : 0.0;

          BudgetAlertLevel level;
          if (percentage >= 100) {
            level = BudgetAlertLevel.exceeded;
          } else if (percentage >= 80) {
            level = BudgetAlertLevel.warning;
          } else {
            level = BudgetAlertLevel.normal;
          }

          final category = categories.firstWhere(
            (c) => c.id == budget.categoryId,
            orElse: () => const CategoryEntity(name: 'Sin categoría'),
          );

          return BudgetWithProgress(
            budget: budget,
            spent: spent,
            remaining: remaining,
            percentage: percentage,
            level: level,
            category: category,
          );
        }),
      );

      final alerts = budgetsWithProgress
          .where((b) => b.level != BudgetAlertLevel.normal)
          .map((b) => BudgetAlert(
                budget: b.budget,
                spent: b.spent,
                percentage: b.percentage,
                level: b.level,
              ))
          .toList();

      final totalBudget =
          periodBudgets.fold<double>(0, (sum, b) => sum + b.limit);
      final totalSpent =
          budgetsWithProgress.fold<double>(0, (sum, b) => sum + b.spent);
      final totalRemaining = totalBudget - totalSpent;

      emit(state.copyWith(
        isLoading: false,
        budgets: periodBudgets,
        budgetsWithProgress: budgetsWithProgress,
        alerts: alerts,
        currentMonth: event.month,
        currentYear: event.year,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        totalRemaining: totalRemaining,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateBudget(
      CreateBudget event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await budgetRepository.createBudget(event.budget);
      final budgets = await budgetRepository.getAllBudgets();
      emit(state.copyWith(
        isLoading: false,
        budgets: budgets,
        successMessage: 'Presupuesto creado exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateBudget(
      UpdateBudget event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await budgetRepository.updateBudget(event.budget);
      final budgets = await budgetRepository.getAllBudgets();
      emit(state.copyWith(
        isLoading: false,
        budgets: budgets,
        successMessage: 'Presupuesto actualizado exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
      DeleteBudget event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await budgetRepository.deleteBudget(event.id);
      final budgets = await budgetRepository.getAllBudgets();
      emit(state.copyWith(
        isLoading: false,
        budgets: budgets,
        successMessage: 'Presupuesto eliminado exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCalculateBudgetAlerts(
      CalculateBudgetAlerts event, Emitter<BudgetState> emit) async {
    try {
      final budgets = await budgetRepository.getAllBudgets();
      final periodBudgets = budgets
          .where(
              (b) => b.periodMonth == event.month && b.periodYear == event.year)
          .toList();
      final alerts =
          await _calculateAlerts(periodBudgets, event.month, event.year);
      emit(state.copyWith(alerts: alerts));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMoveBudgetAmount(
      MoveBudgetAmount event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await budgetRepository.moveBudgetAmount(
        event.fromCategoryId,
        event.toCategoryId,
        event.amount,
        state.currentMonth ?? DateTime.now().month,
        state.currentYear ?? DateTime.now().year,
      );

      // Reload budgets for current period
      add(LoadBudgetsForPeriod(
        month: state.currentMonth ?? DateTime.now().month,
        year: state.currentYear ?? DateTime.now().year,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<List<BudgetAlert>> _calculateAlerts(
      List<BudgetEntity> budgets, int month, int year) async {
    final alerts = <BudgetAlert>[];
    final monthStart = DateTime(year, month);
    final monthEnd = DateTime(year, month + 1, 0);

    for (final budget in budgets) {
      final movements = await movementRepository.getMovementsByDateRange(
          monthStart, monthEnd);
      final categoryMovements = movements.where((m) =>
          m.categoryId == budget.categoryId && m.type == MovementType.expense);
      final spent =
          categoryMovements.fold<double>(0, (sum, m) => sum + m.amount);
      final percentage =
          budget.limit > 0 ? (spent / budget.limit) * 100.0 : 0.0;

      BudgetAlertLevel level;
      if (percentage >= 100) {
        level = BudgetAlertLevel.exceeded;
      } else if (percentage >= 80) {
        level = BudgetAlertLevel.warning;
      } else {
        level = BudgetAlertLevel.normal;
      }

      alerts.add(BudgetAlert(
        budget: budget,
        spent: spent,
        percentage: percentage,
        level: level,
      ));
    }

    return alerts;
  }
}
