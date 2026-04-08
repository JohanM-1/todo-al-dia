// lib/domain/repositories/repositories.dart
import '../entities/entities.dart';

/// Repository interface for managing financial accounts.
abstract class AccountRepository {
  Future<List<AccountEntity>> getAllAccounts();
  Stream<List<AccountEntity>> watchAllAccounts();
  Future<AccountEntity> getAccountById(int id);
  Future<int> createAccount(AccountEntity account);
  Future<bool> updateAccount(AccountEntity account);
}

/// Repository interface for managing transaction categories.
abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Stream<List<CategoryEntity>> watchAllCategories();
  Future<List<CategoryEntity>> getExpenseCategories();
  Future<List<CategoryEntity>> getIncomeCategories();
  Future<int> createCategory(CategoryEntity category);
  Future<bool> updateCategory(CategoryEntity category);
}

/// Repository interface for managing financial movements (income/expense transactions).
abstract class MovementRepository {
  Future<List<MovementEntity>> getAllMovements();
  Stream<List<MovementEntity>> watchAllMovements();
  Future<List<MovementEntity>> getMovementsByDateRange(
      DateTime start, DateTime end);
  Future<List<MovementEntity>> getMovementsByCategory(int categoryId);
  Future<int> createMovement(MovementEntity movement);
  Future<bool> updateMovement(MovementEntity movement);
  Future<int> deleteMovement(int id);
  Future<double> getTotalBalance();
  Future<double> getBalanceForPeriod(DateTime start, DateTime end);
  Future<Map<int, double>> getExpensesByCategory(DateTime start, DateTime end);
  Future<Map<int, int>> getCategoryUsageCount(DateTime start, DateTime end);
}

/// Repository interface for managing spending budgets per category/period.
abstract class BudgetRepository {
  Future<List<BudgetEntity>> getAllBudgets();
  Stream<List<BudgetEntity>> watchAllBudgets();
  Future<BudgetEntity?> getBudgetForCategoryAndPeriod(
      int categoryId, int month, int year);
  Future<int> createBudget(BudgetEntity budget);
  Future<bool> updateBudget(BudgetEntity budget);
  Future<bool> moveBudgetAmount(
      int fromCategoryId, int toCategoryId, double amount, int month, int year);
  Future<int> deleteBudget(int id);
}

/// Repository interface for managing savings goals with contributions.
abstract class GoalRepository {
  Future<List<GoalEntity>> getAllGoals();
  Stream<List<GoalEntity>> watchAllGoals();
  Future<int> createGoal(GoalEntity goal);
  Future<bool> updateGoal(GoalEntity goal);
  Future<int> deleteGoal(int id);
  Future<int> addContribution(int goalId, double amount, String? note);
}
