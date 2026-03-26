// test/domain/entities_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todoaldia/domain/entities/entities.dart';

void main() {
  group('AccountEntity', () {
    test('should create account with required fields', () {
      final account = AccountEntity(
        name: 'Efectivo',
        createdAt: DateTime.now(),
      );

      expect(account.name, 'Efectivo');
      expect(account.currency, 'ARS');
      expect(account.balance, 0.0);
      expect(account.isActive, true);
    });

    test('copyWith should update specified fields', () {
      final account = AccountEntity(
        id: 1,
        name: 'Efectivo',
        createdAt: DateTime.now(),
      );

      final updated = account.copyWith(balance: 1000.0);

      expect(updated.id, 1);
      expect(updated.name, 'Efectivo');
      expect(updated.balance, 1000.0);
    });
  });

  group('MovementEntity', () {
    test('should create expense movement', () {
      final movement = MovementEntity(
        uuid: 'test-uuid',
        accountId: 1,
        categoryId: 1,
        type: MovementType.expense,
        amount: 500.0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(movement.type, MovementType.expense);
      expect(movement.amount, 500.0);
    });

    test('should create income movement', () {
      final movement = MovementEntity(
        uuid: 'test-uuid',
        accountId: 1,
        categoryId: 1,
        type: MovementType.income,
        amount: 1000.0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(movement.type, MovementType.income);
      expect(movement.amount, 1000.0);
    });
  });

  group('GoalEntity', () {
    test('progress should calculate correctly', () {
      final goal = GoalEntity(
        name: 'Vacaciones',
        targetAmount: 1000.0,
        currentAmount: 500.0,
        createdAt: DateTime.now(),
      );

      expect(goal.progress, 0.5);
    });

    test('progress should clamp to 1.0 when over target', () {
      final goal = GoalEntity(
        name: 'Vacaciones',
        targetAmount: 1000.0,
        currentAmount: 1500.0,
        createdAt: DateTime.now(),
      );

      expect(goal.progress, 1.0);
    });

    test('progress should be 0 when target is 0', () {
      final goal = GoalEntity(
        name: 'Meta',
        targetAmount: 0.0,
        currentAmount: 100.0,
        createdAt: DateTime.now(),
      );

      expect(goal.progress, 0.0);
    });
  });

  group('CategoryEntity', () {
    test('should create category with default values', () {
      const category = CategoryEntity(
        name: 'Comida',
      );

      expect(category.name, 'Comida');
      expect(category.icon, '📁');
      expect(category.colorIndex, 0);
      expect(category.isSystem, false);
      expect(category.isIncome, false);
    });
  });
}
