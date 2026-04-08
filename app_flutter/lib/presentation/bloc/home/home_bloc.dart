// lib/presentation/bloc/home/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MovementRepository movementRepository;
  final CategoryRepository categoryRepository;

  HomeBloc({
    required this.movementRepository,
    required this.categoryRepository,
  }) : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Get current month date range
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Fetch all data in parallel
      final results = await Future.wait([
        movementRepository.getTotalBalance(),
        movementRepository.getBalanceForPeriod(monthStart, monthEnd),
        movementRepository.getExpensesByCategory(monthStart, monthEnd),
        movementRepository.getAllMovements(),
        categoryRepository.getAllCategories(),
      ]);

      final totalBalance = results[0] as double;
      // periodBalance used for tracking monthly balance in future extensions
      results[1] as double; // ignore: unused_local_variable
      final expensesByCategory = results[2] as Map<int, double>;
      final movements = results[3] as List<MovementEntity>;
      final categories = results[4] as List<CategoryEntity>;

      // Calculate month income and expenses from period balance
      double monthIncome = 0;
      double monthExpenses = 0;

      for (final m in movements) {
        if (m.date.isAfter(monthStart) && m.date.isBefore(monthEnd)) {
          if (m.type == MovementType.income) {
            monthIncome += m.amount;
          } else {
            monthExpenses += m.amount;
          }
        }
      }

      emit(state.copyWith(
        isLoading: false,
        totalBalance: totalBalance,
        monthIncome: monthIncome,
        monthExpenses: monthExpenses,
        expensesByCategory: expensesByCategory,
        recentMovements: movements.take(10).toList(),
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshHomeData(
      RefreshHomeData event, Emitter<HomeState> emit) async {
    add(LoadHomeData());
  }
}
