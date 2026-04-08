// lib/data/repositories/repository_impl.dart
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../database/app_database.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase _db;

  AccountRepositoryImpl(this._db);

  @override
  Future<List<AccountEntity>> getAllAccounts() async {
    final accounts = await _db.getAllAccounts();
    return accounts.map(_mapToEntity).toList();
  }

  @override
  Stream<List<AccountEntity>> watchAllAccounts() {
    // Simplified: return empty stream, can be enhanced with streams later
    return Stream.value([]);
  }

  @override
  Future<AccountEntity> getAccountById(int id) async {
    final account = await _db.getAccountById(id);
    return _mapToEntity(account);
  }

  @override
  Future<int> createAccount(AccountEntity account) {
    return _db.insertAccount({
      'name': account.name,
      'currency': account.currency,
      'balance': account.balance,
      'is_active': account.isActive ? 1 : 0,
      'created_at': account.createdAt.toIso8601String(),
    });
  }

  @override
  Future<bool> updateAccount(AccountEntity account) async {
    final existing = await _db.getAccountById(account.id!);
    final result = await _db.updateAccount(account.id!, {
      'name': account.name,
      'currency': account.currency,
      'balance': account.balance,
      'is_active': account.isActive ? 1 : 0,
      'created_at':
          existing['created_at'] ?? account.createdAt.toIso8601String(),
    });
    return result > 0;
  }

  AccountEntity _mapToEntity(Map<String, dynamic> map) {
    return AccountEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      currency: map['currency'] as String? ?? 'COP',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  static const _leadingWhitespacePattern = r'^\s+';

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final categories = await _db.getAllCategories();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Stream<List<CategoryEntity>> watchAllCategories() {
    return Stream.value([]);
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories() async {
    final categories = await _db.getExpenseCategories();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories() async {
    final categories = await _db.getIncomeCategories();
    return categories.map(_mapToEntity).toList();
  }

  @override
  Future<int> createCategory(CategoryEntity category) {
    final normalizedName =
        _normalizeCategoryName(category.name, iconsToStrip: [category.icon]);
    return _db.insertCategory({
      'name': normalizedName,
      'icon': category.icon,
      'color_index': category.colorIndex,
      'is_system': category.isSystem ? 1 : 0,
      'is_income': category.isIncome ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<bool> updateCategory(CategoryEntity category) async {
    final existing = await _db.getAllCategories();
    final cat = existing.firstWhere(
      (c) => c['id'] == category.id,
      orElse: () => {},
    );
    final normalizedName = _normalizeCategoryName(
      category.name,
      iconsToStrip: [category.icon, cat['icon'] as String?],
    );
    final result = await _db.updateCategory(category.id!, {
      'name': normalizedName,
      'icon': category.icon,
      'color_index': category.colorIndex,
      'is_system': category.isSystem ? 1 : 0,
      'is_income': category.isIncome ? 1 : 0,
      'created_at': cat['created_at'] ?? DateTime.now().toIso8601String(),
    });
    return result > 0;
  }

  CategoryEntity _mapToEntity(Map<String, dynamic> map) {
    final icon = map['icon'] as String? ?? '📁';
    return CategoryEntity(
      id: map['id'] as int?,
      name: _normalizeCategoryName(
        map['name'] as String? ?? '',
        iconsToStrip: [icon],
      ),
      icon: icon,
      colorIndex: map['color_index'] as int? ?? 0,
      isSystem: (map['is_system'] as int?) == 1,
      isIncome: (map['is_income'] as int?) == 1,
    );
  }

  String _normalizeCategoryName(
    String rawName, {
    required Iterable<String?> iconsToStrip,
  }) {
    var normalizedName = rawName.trim();
    if (normalizedName.isEmpty) {
      return normalizedName;
    }

    for (final icon in iconsToStrip.whereType<String>()) {
      if (icon.isEmpty || !normalizedName.startsWith(icon)) {
        continue;
      }

      normalizedName = normalizedName
          .substring(icon.length)
          .replaceFirst(RegExp(_leadingWhitespacePattern), '');
    }

    return normalizedName;
  }
}

class MovementRepositoryImpl implements MovementRepository {
  final AppDatabase _db;

  MovementRepositoryImpl(this._db);

  @override
  Future<List<MovementEntity>> getAllMovements() async {
    final movements = await _db.getAllMovements();
    return movements.map(_mapToEntity).toList();
  }

  @override
  Stream<List<MovementEntity>> watchAllMovements() {
    return Stream.value([]);
  }

  @override
  Future<List<MovementEntity>> getMovementsByDateRange(
      DateTime start, DateTime end) async {
    final movements = await _db.getMovementsByDateRange(start, end);
    return movements.map(_mapToEntity).toList();
  }

  @override
  Future<List<MovementEntity>> getMovementsByCategory(int categoryId) async {
    final movements = await _db.getMovementsByCategory(categoryId);
    return movements.map(_mapToEntity).toList();
  }

  @override
  Future<int> createMovement(MovementEntity movement) {
    final now = DateTime.now();
    return _db.insertMovement({
      'uuid': movement.uuid,
      'account_id': movement.accountId,
      'category_id': movement.categoryId,
      'type': movement.type == MovementType.expense ? 'expense' : 'income',
      'amount': movement.amount,
      'note': movement.note,
      'merchant': movement.merchant,
      'payment_method': movement.paymentMethod,
      'date': movement.date.toIso8601String(),
      'created_at': now.toIso8601String(),
    });
  }

  @override
  Future<bool> updateMovement(MovementEntity movement) async {
    final result = await _db.updateMovement(movement.id!, {
      'uuid': movement.uuid,
      'account_id': movement.accountId,
      'category_id': movement.categoryId,
      'type': movement.type == MovementType.expense ? 'expense' : 'income',
      'amount': movement.amount,
      'note': movement.note,
      'merchant': movement.merchant,
      'payment_method': movement.paymentMethod,
      'date': movement.date.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    return result > 0;
  }

  @override
  Future<int> deleteMovement(int id) {
    return _db.deleteMovement(id);
  }

  @override
  Future<double> getTotalBalance() => _db.getTotalBalance();

  @override
  Future<double> getBalanceForPeriod(DateTime start, DateTime end) =>
      _db.getBalanceForPeriod(start, end);

  @override
  Future<Map<int, double>> getExpensesByCategory(
          DateTime start, DateTime end) =>
      _db.getExpensesByCategory(start, end);

  @override
  Future<Map<int, int>> getCategoryUsageCount(DateTime start, DateTime end) =>
      _db.getCategoryUsageCount(start, end);

  MovementEntity _mapToEntity(Map<String, dynamic> map) {
    return MovementEntity(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      accountId: map['account_id'] as int,
      categoryId: map['category_id'] as int,
      type:
          map['type'] == 'expense' ? MovementType.expense : MovementType.income,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      merchant: map['merchant'] as String?,
      paymentMethod: map['payment_method'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }
}

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _db;

  BudgetRepositoryImpl(this._db);

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    final budgets = await _db.getAllBudgets();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Stream<List<BudgetEntity>> watchAllBudgets() {
    return Stream.value([]);
  }

  @override
  Future<BudgetEntity?> getBudgetForCategoryAndPeriod(
      int categoryId, int month, int year) async {
    final budget =
        await _db.getBudgetForCategoryAndPeriod(categoryId, month, year);
    return budget != null ? _mapToEntity(budget) : null;
  }

  @override
  Future<int> createBudget(BudgetEntity budget) {
    return _db.insertBudget({
      'category_id': budget.categoryId,
      'budget_limit': budget.limit,
      'period_month': budget.periodMonth,
      'period_year': budget.periodYear,
      'created_at': budget.createdAt.toIso8601String(),
    });
  }

  @override
  Future<bool> updateBudget(BudgetEntity budget) async {
    final existing = await _db.getAllBudgets();
    final bud = existing.firstWhere(
      (b) => b['id'] == budget.id,
      orElse: () => {},
    );
    final result = await _db.updateBudget(budget.id!, {
      'category_id': budget.categoryId,
      'budget_limit': budget.limit,
      'period_month': budget.periodMonth,
      'period_year': budget.periodYear,
      'created_at': bud['created_at'] ?? budget.createdAt.toIso8601String(),
    });
    return result > 0;
  }

  Future<bool> moveBudgetAmount(int fromCategoryId, int toCategoryId,
      double amount, int month, int year) async {
    final budgets = await _db.getAllBudgets();
    final fromBudget = budgets
        .where((b) =>
            b['category_id'] == fromCategoryId &&
            b['period_month'] == month &&
            b['period_year'] == year)
        .firstOrNull;
    final toBudget = budgets
        .where((b) =>
            b['category_id'] == toCategoryId &&
            b['period_month'] == month &&
            b['period_year'] == year)
        .firstOrNull;

    if (fromBudget == null || toBudget == null) return false;

    final fromLimit = (fromBudget['budget_limit'] as num).toDouble();
    final toLimit = (toBudget['budget_limit'] as num).toDouble();

    if (fromLimit < amount) return false;

    await _db.updateBudget(fromBudget['id'] as int, {
      ...fromBudget,
      'budget_limit': fromLimit - amount,
    });
    await _db.updateBudget(toBudget['id'] as int, {
      ...toBudget,
      'budget_limit': toLimit + amount,
    });
    return true;
  }

  @override
  Future<int> deleteBudget(int id) => _db.deleteBudget(id);

  BudgetEntity _mapToEntity(Map<String, dynamic> map) {
    return BudgetEntity(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      limit: (map['budget_limit'] as num).toDouble(),
      spent: (map['spent'] as num?)?.toDouble() ?? 0,
      remaining: (map['remaining'] as num?)?.toDouble() ?? 0,
      periodMonth: map['period_month'] as int,
      periodYear: map['period_year'] as int,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class GoalRepositoryImpl implements GoalRepository {
  final AppDatabase _db;

  GoalRepositoryImpl(this._db);

  @override
  Future<List<GoalEntity>> getAllGoals() async {
    final goals = await _db.getAllGoals();
    return goals.map(_mapToEntity).toList();
  }

  @override
  Stream<List<GoalEntity>> watchAllGoals() {
    return Stream.value([]);
  }

  @override
  Future<int> createGoal(GoalEntity goal) {
    return _db.insertGoal({
      'name': goal.name,
      'goal_type': goal.goalType.name,
      'target_amount': goal.targetAmount,
      'current_amount': goal.currentAmount,
      'target_date': goal.targetDate?.toIso8601String(),
      'is_completed': goal.isCompleted ? 1 : 0,
      'is_paused': goal.isPaused ? 1 : 0,
      'created_at': goal.createdAt.toIso8601String(),
    });
  }

  @override
  Future<bool> updateGoal(GoalEntity goal) async {
    final existing = await _db.getAllGoals();
    final g = existing.firstWhere(
      (g) => g['id'] == goal.id,
      orElse: () => {},
    );
    final result = await _db.updateGoal(goal.id!, {
      'name': goal.name,
      'goal_type': goal.goalType.name,
      'target_amount': goal.targetAmount,
      'current_amount': goal.currentAmount,
      'target_date': goal.targetDate?.toIso8601String(),
      'is_completed': goal.isCompleted ? 1 : 0,
      'is_paused': goal.isPaused ? 1 : 0,
      'created_at': g['created_at'] ?? goal.createdAt.toIso8601String(),
    });
    return result > 0;
  }

  @override
  Future<int> deleteGoal(int id) => _db.deleteGoal(id);

  @override
  Future<int> addContribution(int goalId, double amount, String? note) async {
    final goals = await _db.getAllGoals();
    final goalMap = goals.firstWhere(
      (g) => g['id'] == goalId,
      orElse: () => throw Exception('Goal not found'),
    );

    final currentAmount =
        (goalMap['current_amount'] as num?)?.toDouble() ?? 0.0;
    final newAmount = currentAmount + amount;
    final isCompleted =
        newAmount >= (goalMap['target_amount'] as num).toDouble();

    await _db.updateGoal(goalId, {
      'name': goalMap['name'],
      'goal_type': goalMap['goal_type'] ?? 'savings',
      'target_amount': goalMap['target_amount'],
      'current_amount': newAmount,
      'target_date': goalMap['target_date'],
      'is_completed': isCompleted ? 1 : 0,
      'is_paused': goalMap['is_paused'] ?? 0,
    });

    return _db.addGoalContribution({
      'goal_id': goalId,
      'amount': amount,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  GoalEntity _mapToEntity(Map<String, dynamic> map) {
    return GoalEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      goalType: _parseGoalType(map['goal_type'] as String?),
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['target_date'] != null
          ? DateTime.tryParse(map['target_date'] as String)
          : null,
      isCompleted: (map['is_completed'] as int?) == 1,
      isPaused: (map['is_paused'] as int?) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  GoalType _parseGoalType(String? type) {
    switch (type) {
      case 'expenseControl':
        return GoalType.expenseControl;
      case 'event':
        return GoalType.event;
      default:
        return GoalType.savings;
    }
  }
}
