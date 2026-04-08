// lib/presentation/bloc/home/home_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final double totalBalance;
  final double monthIncome;
  final double monthExpenses;
  final Map<int, double> expensesByCategory;
  final List<MovementEntity> recentMovements;
  final List<CategoryEntity> categories;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.totalBalance = 0,
    this.monthIncome = 0,
    this.monthExpenses = 0,
    this.expensesByCategory = const {},
    this.recentMovements = const [],
    this.categories = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    double? totalBalance,
    double? monthIncome,
    double? monthExpenses,
    Map<int, double>? expensesByCategory,
    List<MovementEntity>? recentMovements,
    List<CategoryEntity>? categories,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      totalBalance: totalBalance ?? this.totalBalance,
      monthIncome: monthIncome ?? this.monthIncome,
      monthExpenses: monthExpenses ?? this.monthExpenses,
      expensesByCategory: expensesByCategory ?? this.expensesByCategory,
      recentMovements: recentMovements ?? this.recentMovements,
      categories: categories ?? this.categories,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        totalBalance,
        monthIncome,
        monthExpenses,
        expensesByCategory,
        recentMovements,
        categories,
        error
      ];
}
