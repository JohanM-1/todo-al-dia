// lib/presentation/bloc/budget/budget_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class LoadBudgetsForPeriod extends BudgetEvent {
  final int month;
  final int year;

  const LoadBudgetsForPeriod({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class CreateBudget extends BudgetEvent {
  final BudgetEntity budget;

  const CreateBudget({required this.budget});

  @override
  List<Object?> get props => [budget];
}

class UpdateBudget extends BudgetEvent {
  final BudgetEntity budget;

  const UpdateBudget({required this.budget});

  @override
  List<Object?> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  final int id;

  const DeleteBudget({required this.id});

  @override
  List<Object?> get props => [id];
}

class CalculateBudgetAlerts extends BudgetEvent {
  final int month;
  final int year;

  const CalculateBudgetAlerts({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class MoveBudgetAmount extends BudgetEvent {
  final int fromCategoryId;
  final int toCategoryId;
  final double amount;

  const MoveBudgetAmount({
    required this.fromCategoryId,
    required this.toCategoryId,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromCategoryId, toCategoryId, amount];
}
