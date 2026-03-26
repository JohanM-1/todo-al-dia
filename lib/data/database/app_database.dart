// lib/data/database/app_database.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppDatabase {
  static bool _initialized = false;
  static final AppDatabase instance = AppDatabase._();

  // Cache for currency (sync access)
  static String _cachedCurrency = 'ARS';

  AppDatabase._();

  // Boxes
  late Box<Map<dynamic, dynamic>> _accountsBox;
  late Box<Map<dynamic, dynamic>> _categoriesBox;
  late Box<Map<dynamic, dynamic>> _movementsBox;
  late Box<Map<dynamic, dynamic>> _budgetsBox;
  late Box<Map<dynamic, dynamic>> _goalsBox;
  late Box<Map<dynamic, dynamic>> _goalContributionsBox;
  late Box<Map<dynamic, dynamic>> _settingsBox;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _accountsBox = await Hive.openBox<Map<dynamic, dynamic>>('accounts');
    _categoriesBox = await Hive.openBox<Map<dynamic, dynamic>>('categories');
    _movementsBox = await Hive.openBox<Map<dynamic, dynamic>>('movements');
    _budgetsBox = await Hive.openBox<Map<dynamic, dynamic>>('budgets');
    _goalsBox = await Hive.openBox<Map<dynamic, dynamic>>('goals');
    _goalContributionsBox =
        await Hive.openBox<Map<dynamic, dynamic>>('goal_contributions');
    _settingsBox = await Hive.openBox<Map<dynamic, dynamic>>('settings');

    // Seed initial data if empty
    if (_categoriesBox.isEmpty) {
      await _seedInitialData();
    }

    // Load currency cache
    final currencySetting = _settingsBox.get('currency');
    if (currencySetting != null) {
      _cachedCurrency = currencySetting['value'] as String? ?? 'ARS';
    }

    _initialized = true;
  }

  Future<void> _seedInitialData() async {
    final now = DateTime.now().toIso8601String();

    // Default account
    await _accountsBox.add({
      'name': 'Efectivo',
      'currency': 'ARS',
      'balance': 0.0,
      'is_active': 1,
      'created_at': now,
    });

    // System categories - Expenses
    final expenseCategories = [
      {'name': '🍔 Comida', 'icon': '🍔', 'color_index': 0},
      {'name': '🚗 Transporte', 'icon': '🚗', 'color_index': 1},
      {'name': '🏠 Casa', 'icon': '🏠', 'color_index': 2},
      {'name': '🎬 Entretenimiento', 'icon': '🎬', 'color_index': 3},
      {'name': '🛒 Supermercado', 'icon': '🛒', 'color_index': 4},
      {'name': '💊 Salud', 'icon': '💊', 'color_index': 5},
      {'name': '👕 Ropa', 'icon': '👕', 'color_index': 6},
      {'name': '📱 Servicios', 'icon': '📱', 'color_index': 7},
      {'name': '🎁 Regalos', 'icon': '🎁', 'color_index': 8},
      {'name': '📦 Otros', 'icon': '📦', 'color_index': 9},
    ];

    for (final cat in expenseCategories) {
      await _categoriesBox.add({
        ...cat,
        'is_system': 1,
        'is_income': 0,
        'created_at': now,
      });
    }

    // System categories - Income
    final incomeCategories = [
      {'name': '💰 Salario', 'icon': '💰', 'color_index': 0},
      {'name': '💵 Freelance', 'icon': '💵', 'color_index': 1},
      {'name': '🎁 Regalo', 'icon': '🎁', 'color_index': 2},
      {'name': '📈 Inversión', 'icon': '📈', 'color_index': 3},
      {'name': '💎 Venta', 'icon': '💎', 'color_index': 4},
      {'name': '➕ Otros Ingresos', 'icon': '➕', 'color_index': 5},
    ];

    for (final cat in incomeCategories) {
      await _categoriesBox.add({
        ...cat,
        'is_system': 1,
        'is_income': 1,
        'created_at': now,
      });
    }

    // Default settings
    await _settingsBox.put('currency', {'key': 'currency', 'value': 'ARS'});
    await _settingsBox.put('onboarding_complete',
        {'key': 'onboarding_complete', 'value': 'false'});
  }

  List<Map<String, dynamic>> _readBoxEntries(
    Box<Map<dynamic, dynamic>> box, {
    bool Function(Map<String, dynamic> item)? where,
  }) {
    return box.keys
        .map((key) {
          final value = box.get(key);
          if (value == null) return null;

          final item = Map<String, dynamic>.from(value);
          if (key is int) {
            item['id'] = key;
          }
          return item;
        })
        .whereType<Map<String, dynamic>>()
        .where((item) => where?.call(item) ?? true)
        .toList();
  }

  Map<String, dynamic> _readBoxEntryById(
      Box<Map<dynamic, dynamic>> box, int id) {
    final value = box.get(id);
    if (value == null) return {};

    return {
      ...Map<String, dynamic>.from(value),
      'id': id,
    };
  }

  Future<int> _updateBoxEntry(
    Box<Map<dynamic, dynamic>> box,
    int id,
    Map<String, dynamic> item,
  ) async {
    await box.put(id, item);
    return id;
  }

  Future<int> _deleteBoxEntry(Box<Map<dynamic, dynamic>> box, int id) async {
    await box.delete(id);
    return id;
  }

  // Account operations
  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    return _readBoxEntries(_accountsBox);
  }

  Future<Map<String, dynamic>> getAccountById(int id) async {
    return _readBoxEntryById(_accountsBox, id);
  }

  Future<int> insertAccount(Map<String, dynamic> account) async {
    return await _accountsBox.add(account);
  }

  Future<int> updateAccount(int id, Map<String, dynamic> account) async {
    return _updateBoxEntry(_accountsBox, id, account);
  }

  // Category operations
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    return _readBoxEntries(_categoriesBox);
  }

  Future<List<Map<String, dynamic>>> getExpenseCategories() async {
    return _readBoxEntries(
      _categoriesBox,
      where: (category) => category['is_income'] == 0,
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeCategories() async {
    return _readBoxEntries(
      _categoriesBox,
      where: (category) => category['is_income'] == 1,
    );
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    return await _categoriesBox.add(category);
  }

  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    return _updateBoxEntry(_categoriesBox, id, category);
  }

  // Movement operations
  Future<List<Map<String, dynamic>>> getAllMovements() async {
    final movements = _readBoxEntries(_movementsBox);
    movements.sort((a, b) => DateTime.parse(b['date'] as String)
        .compareTo(DateTime.parse(a['date'] as String)));
    return movements;
  }

  Future<List<Map<String, dynamic>>> getMovementsByDateRange(
      DateTime start, DateTime end) async {
    final movements = _readBoxEntries(
      _movementsBox,
      where: (movement) {
        final date = DateTime.parse(movement['date'] as String);
        return date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1)));
      },
    );
    movements.sort((a, b) => DateTime.parse(b['date'] as String)
        .compareTo(DateTime.parse(a['date'] as String)));
    return movements;
  }

  Future<List<Map<String, dynamic>>> getMovementsByCategory(
      int categoryId) async {
    final movements = _readBoxEntries(
      _movementsBox,
      where: (movement) => movement['category_id'] == categoryId,
    );
    movements.sort((a, b) => DateTime.parse(b['date'] as String)
        .compareTo(DateTime.parse(a['date'] as String)));
    return movements;
  }

  Future<int> insertMovement(Map<String, dynamic> movement) async {
    return await _movementsBox.add(movement);
  }

  Future<int> updateMovement(int id, Map<String, dynamic> movement) async {
    return _updateBoxEntry(_movementsBox, id, movement);
  }

  Future<int> deleteMovement(int id) async {
    return _deleteBoxEntry(_movementsBox, id);
  }

  // Balance operations
  Future<double> getTotalBalance() async {
    final movements = await getAllMovements();
    double balance = 0;
    for (final m in movements) {
      if (m['type'] == 'income') {
        balance += (m['amount'] as num).toDouble();
      } else {
        balance -= (m['amount'] as num).toDouble();
      }
    }
    return balance;
  }

  Future<double> getBalanceForPeriod(DateTime start, DateTime end) async {
    final movements = await getMovementsByDateRange(start, end);
    double balance = 0;
    for (final m in movements) {
      if (m['type'] == 'income') {
        balance += (m['amount'] as num).toDouble();
      } else {
        balance -= (m['amount'] as num).toDouble();
      }
    }
    return balance;
  }

  Future<Map<int, double>> getExpensesByCategory(
      DateTime start, DateTime end) async {
    final movements = await getMovementsByDateRange(start, end);
    final Map<int, double> result = {};
    for (final m in movements) {
      if (m['type'] == 'expense') {
        final categoryId = m['category_id'] as int;
        final amount = (m['amount'] as num).toDouble();
        result[categoryId] = (result[categoryId] ?? 0) + amount;
      }
    }
    return result;
  }

  /// Get category usage frequency (count of movements per category)
  Future<Map<int, int>> getCategoryUsageCount(
      DateTime start, DateTime end) async {
    final movements = await getMovementsByDateRange(start, end);
    final Map<int, int> result = {};
    for (final m in movements) {
      final categoryId = m['category_id'] as int;
      result[categoryId] = (result[categoryId] ?? 0) + 1;
    }
    return result;
  }

  // Budget operations
  Future<List<Map<String, dynamic>>> getAllBudgets() async {
    return _readBoxEntries(_budgetsBox);
  }

  Future<Map<String, dynamic>?> getBudgetForCategoryAndPeriod(
      int categoryId, int month, int year) async {
    final budgets = _readBoxEntries(
      _budgetsBox,
      where: (budget) =>
          budget['category_id'] == categoryId &&
          budget['period_month'] == month &&
          budget['period_year'] == year,
    );
    return budgets.isNotEmpty ? budgets.first : null;
  }

  Future<int> insertBudget(Map<String, dynamic> budget) async {
    return await _budgetsBox.add(budget);
  }

  Future<int> updateBudget(int id, Map<String, dynamic> budget) async {
    return _updateBoxEntry(_budgetsBox, id, budget);
  }

  Future<int> deleteBudget(int id) async {
    return _deleteBoxEntry(_budgetsBox, id);
  }

  // Goal operations
  Future<List<Map<String, dynamic>>> getAllGoals() async {
    return _readBoxEntries(_goalsBox);
  }

  Future<int> insertGoal(Map<String, dynamic> goal) async {
    return await _goalsBox.add(goal);
  }

  Future<int> updateGoal(int id, Map<String, dynamic> goal) async {
    return _updateBoxEntry(_goalsBox, id, goal);
  }

  Future<int> deleteGoal(int id) async {
    return _deleteBoxEntry(_goalsBox, id);
  }

  Future<int> addGoalContribution(Map<String, dynamic> contribution) async {
    return await _goalContributionsBox.add(contribution);
  }

  /// Load and cache currency from settings.
  /// Call this on app startup to ensure currency is available.
  Future<void> loadCurrencyCache() async {
    final currency = await getSetting('currency');
    if (currency != null) {
      _cachedCurrency = currency;
    }
  }

  // Settings operations
  Future<String?> getSetting(String key) async {
    final setting = _settingsBox.get(key);
    return setting?['value'] as String?;
  }

  /// Get currency synchronously from cache.
  /// Returns 'ARS' if not yet initialized.
  static String get currentCurrency => _cachedCurrency;

  Future<void> setSetting(String key, String value) async {
    await _settingsBox.put(key, {'key': key, 'value': value});
    // Cache currency when updated
    if (key == 'currency') {
      _cachedCurrency = value;
    }
  }

  // Theme color setting
  Future<Color?> getThemeColor() async {
    final hex = await getSetting('theme_color');
    if (hex == null || hex.isEmpty) return null;
    try {
      final colorValue = int.parse(hex.replaceFirst('#', ''), radix: 16);
      return Color(0xFF000000 | colorValue);
    } catch (_) {
      return null;
    }
  }

  Future<void> setThemeColor(Color color) async {
    final hex =
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    await setSetting('theme_color', hex);
  }

  // Language setting
  Future<String?> getLanguage() async {
    return await getSetting('language');
  }

  Future<void> setLanguage(String languageCode) async {
    await setSetting('language', languageCode);
  }

  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }
}
