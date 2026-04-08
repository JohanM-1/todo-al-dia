// lib/domain/entities/entities.dart
import 'package:equatable/equatable.dart';

/// Represents a financial account (e.g., cash, bank account).
/// Each account has a name, currency, and balance tracking.
class AccountEntity extends Equatable {
  final int? id;
  final String name;
  final String currency;
  final double balance;
  final bool isActive;
  final DateTime createdAt;

  const AccountEntity({
    this.id,
    required this.name,
    this.currency = 'ARS',
    this.balance = 0.0,
    this.isActive = true,
    required this.createdAt,
  });

  AccountEntity copyWith({
    int? id,
    String? name,
    String? currency,
    double? balance,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, currency, balance, isActive, createdAt];
}

/// Represents a transaction category for organizing movements.
/// Categories can be system-defined (default) or user-created.
class CategoryEntity extends Equatable {
  final int? id;
  final String name;
  final String icon;
  final int colorIndex;
  final bool isSystem;
  final bool isIncome;

  const CategoryEntity({
    this.id,
    required this.name,
    this.icon = '📁',
    this.colorIndex = 0,
    this.isSystem = false,
    this.isIncome = false,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? icon,
    int? colorIndex,
    bool? isSystem,
    bool? isIncome,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorIndex: colorIndex ?? this.colorIndex,
      isSystem: isSystem ?? this.isSystem,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, colorIndex, isSystem, isIncome];
}

/// Type of financial movement.
enum MovementType { expense, income }

/// Represents a savings goal type
enum GoalType { savings, expenseControl, event }

/// Represents a spending limit for a category in a specific month/year period.
/// Used for budget tracking and alerts.
class BudgetEntity extends Equatable {
  final int? id;
  final int categoryId;
  final double limit;
  final double spent;
  final double remaining;
  final int periodMonth;
  final int periodYear;
  final DateTime createdAt;

  const BudgetEntity({
    this.id,
    required this.categoryId,
    required this.limit,
    this.spent = 0,
    this.remaining = 0,
    required this.periodMonth,
    required this.periodYear,
    required this.createdAt,
  });

  double get percentage => limit > 0 ? (spent / limit) * 100.0 : 0;

  BudgetEntity copyWith({
    int? id,
    int? categoryId,
    double? limit,
    double? spent,
    double? remaining,
    int? periodMonth,
    int? periodYear,
    DateTime? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      remaining: remaining ?? this.remaining,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        limit,
        spent,
        remaining,
        periodMonth,
        periodYear,
        createdAt
      ];
}

/// Represents a financial transaction (income or expense).
/// Contains all details about a movement including amount, category, date, and optional metadata.
class MovementEntity extends Equatable {
  final int? id;
  final String uuid;
  final int accountId;
  final int categoryId;
  final MovementType type;
  final double amount;
  final String? note;
  final String? merchant;
  final String? paymentMethod;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MovementEntity({
    this.id,
    required this.uuid,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    this.merchant,
    this.paymentMethod,
    required this.date,
    required this.createdAt,
    this.updatedAt,
  });

  MovementEntity copyWith({
    int? id,
    String? uuid,
    int? accountId,
    int? categoryId,
    MovementType? type,
    double? amount,
    String? note,
    String? merchant,
    String? paymentMethod,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MovementEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      merchant: merchant ?? this.merchant,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        accountId,
        categoryId,
        type,
        amount,
        note,
        merchant,
        paymentMethod,
        date,
        createdAt,
        updatedAt
      ];
}

/// Represents a savings goal with a target amount and optional target date.
/// Tracks progress through contributions and calculates completion percentage.
class GoalEntity extends Equatable {
  final int? id;
  final String name;
  final GoalType goalType;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final bool isCompleted;
  final bool isPaused;
  final DateTime createdAt;

  const GoalEntity({
    this.id,
    required this.name,
    this.goalType = GoalType.savings,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.isCompleted = false,
    this.isPaused = false,
    required this.createdAt,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  int? get estimatedDaysLeft {
    if (targetDate == null || currentAmount >= targetAmount) return null;
    final daysUntilTarget = targetDate!.difference(DateTime.now()).inDays;
    if (daysUntilTarget <= 0) return 0;
    final remaining = targetAmount - currentAmount;
    final daysPassed = DateTime.now().difference(createdAt).inDays;
    if (daysPassed <= 0) return daysUntilTarget;
    final avgDailySavings = currentAmount / daysPassed;
    if (avgDailySavings <= 0) return null;
    return (remaining / avgDailySavings).ceil();
  }

  GoalEntity copyWith({
    int? id,
    String? name,
    GoalType? goalType,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    bool? isCompleted,
    bool? isPaused,
    DateTime? createdAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      goalType: goalType ?? this.goalType,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isPaused: isPaused ?? this.isPaused,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        goalType,
        targetAmount,
        currentAmount,
        targetDate,
        isCompleted,
        isPaused,
        createdAt
      ];
}
