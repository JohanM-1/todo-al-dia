// test/data/repositories/movement_repository_test.dart
//
// Unit tests for MovementRepository CRUD operations.
// Uses mocktail to mock the AppDatabase dependency.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaldia/data/repositories/repository_impl.dart';
import 'package:todoaldia/data/database/app_database.dart';
import 'package:todoaldia/domain/entities/entities.dart';

// Mock class for AppDatabase
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MovementRepositoryImpl movementRepository;
  late MockAppDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockAppDatabase();
    movementRepository = MovementRepositoryImpl(mockDatabase);
  });

  setUpAll(() {
    // Register fallback values for non-mocked methods
    registerFallbackValue(DateTime.now());
  });

  group('MovementRepositoryImpl - CRUD Operations', () {
    final testMovement = MovementEntity(
      id: 1,
      uuid: 'test-uuid-123',
      accountId: 1,
      categoryId: 1,
      type: MovementType.expense,
      amount: 500.0,
      note: 'Test expense',
      merchant: 'Test Store',
      paymentMethod: 'efectivo',
      date: DateTime(2024, 1, 15),
      createdAt: DateTime(2024, 1, 15),
    );

    final testMovementMap = {
      'id': 1,
      'uuid': 'test-uuid-123',
      'account_id': 1,
      'category_id': 1,
      'type': 'expense',
      'amount': 500.0,
      'note': 'Test expense',
      'merchant': 'Test Store',
      'payment_method': 'efectivo',
      'date': '2024-01-15T00:00:00.000',
      'created_at': '2024-01-15T00:00:00.000',
    };

    group('getAllMovements', () {
      test('should return list of movements from database', () async {
        // Arrange
        when(() => mockDatabase.getAllMovements())
            .thenAnswer((_) async => [testMovementMap]);

        // Act
        final result = await movementRepository.getAllMovements();

        // Assert
        expect(result, isA<List<MovementEntity>>());
        expect(result.length, 1);
        expect(result.first.uuid, 'test-uuid-123');
        expect(result.first.amount, 500.0);
        expect(result.first.type, MovementType.expense);
        verify(() => mockDatabase.getAllMovements()).called(1);
      });

      test('should return empty list when no movements', () async {
        // Arrange
        when(() => mockDatabase.getAllMovements()).thenAnswer((_) async => []);

        // Act
        final result = await movementRepository.getAllMovements();

        // Assert
        expect(result, isEmpty);
        verify(() => mockDatabase.getAllMovements()).called(1);
      });

      test('should map income type correctly', () async {
        // Arrange
        final incomeMap = {...testMovementMap, 'type': 'income'};
        when(() => mockDatabase.getAllMovements())
            .thenAnswer((_) async => [incomeMap]);

        // Act
        final result = await movementRepository.getAllMovements();

        // Assert
        expect(result.first.type, MovementType.income);
      });
    });

    group('getMovementsByDateRange', () {
      test('should return movements within date range', () async {
        // Arrange
        final start = DateTime(2024);
        final end = DateTime(2024, 1, 31);
        when(() => mockDatabase.getMovementsByDateRange(start, end))
            .thenAnswer((_) async => [testMovementMap]);

        // Act
        final result =
            await movementRepository.getMovementsByDateRange(start, end);

        // Assert
        expect(result.length, 1);
        verify(() => mockDatabase.getMovementsByDateRange(start, end))
            .called(1);
      });

      test('should return empty list when no movements in range', () async {
        // Arrange
        final start = DateTime(2024, 2);
        final end = DateTime(2024, 2, 28);
        when(() => mockDatabase.getMovementsByDateRange(start, end))
            .thenAnswer((_) async => []);

        // Act
        final result =
            await movementRepository.getMovementsByDateRange(start, end);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getMovementsByCategory', () {
      test('should return movements for specific category', () async {
        // Arrange
        const categoryId = 5;
        when(() => mockDatabase.getMovementsByCategory(categoryId))
            .thenAnswer((_) async => [testMovementMap]);

        // Act
        final result =
            await movementRepository.getMovementsByCategory(categoryId);

        // Assert
        expect(result.length, 1);
        expect(result.first.categoryId, 1); // From testMovementMap
        verify(() => mockDatabase.getMovementsByCategory(categoryId)).called(1);
      });

      test('should return empty list for unknown category', () async {
        // Arrange
        const categoryId = 999;
        when(() => mockDatabase.getMovementsByCategory(categoryId))
            .thenAnswer((_) async => []);

        // Act
        final result =
            await movementRepository.getMovementsByCategory(categoryId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('createMovement', () {
      test('should insert movement and return id', () async {
        // Arrange
        when(() => mockDatabase.insertMovement(any()))
            .thenAnswer((_) async => 42);

        // Act
        final result = await movementRepository.createMovement(testMovement);

        // Assert
        expect(result, 42);
        verify(() => mockDatabase.insertMovement(any())).called(1);
      });

      test('should convert expense type to string', () async {
        // Arrange
        Map<String, dynamic>? capturedMap;
        when(() => mockDatabase.insertMovement(any()))
            .thenAnswer((invocation) async {
          capturedMap =
              invocation.positionalArguments[0] as Map<String, dynamic>;
          return 1;
        });

        // Act
        await movementRepository.createMovement(testMovement);

        // Assert
        expect(capturedMap!['type'], 'expense');
      });

      test('should convert income type to string', () async {
        // Arrange
        Map<String, dynamic>? capturedMap;
        when(() => mockDatabase.insertMovement(any()))
            .thenAnswer((invocation) async {
          capturedMap =
              invocation.positionalArguments[0] as Map<String, dynamic>;
          return 1;
        });

        final incomeMovement = testMovement.copyWith(type: MovementType.income);

        // Act
        await movementRepository.createMovement(incomeMovement);

        // Assert
        expect(capturedMap!['type'], 'income');
      });
    });

    group('updateMovement', () {
      test('should update movement and return success', () async {
        // Arrange
        final updatedMovement = testMovement.copyWith(amount: 750.0);
        when(() => mockDatabase.updateMovement(any(), any()))
            .thenAnswer((_) async => 1);

        // Act
        final result = await movementRepository.updateMovement(updatedMovement);

        // Assert
        expect(result, true);
        verify(() => mockDatabase.updateMovement(any(), any())).called(1);
      });

      test('should return false when update fails', () async {
        // Arrange
        when(() => mockDatabase.updateMovement(any(), any()))
            .thenAnswer((_) async => 0);

        // Act
        final result = await movementRepository.updateMovement(testMovement);

        // Assert
        expect(result, false);
      });
    });

    group('deleteMovement', () {
      test('should delete movement and return id', () async {
        // Arrange
        when(() => mockDatabase.deleteMovement(any()))
            .thenAnswer((_) async => 1);

        // Act
        final result = await movementRepository.deleteMovement(1);

        // Assert
        expect(result, 1);
        verify(() => mockDatabase.deleteMovement(1)).called(1);
      });
    });
  });

  group('MovementRepositoryImpl - Balance Operations', () {
    group('getTotalBalance', () {
      test('should return total balance from database', () async {
        // Arrange
        when(() => mockDatabase.getTotalBalance())
            .thenAnswer((_) async => 1500.0);

        // Act
        final result = await movementRepository.getTotalBalance();

        // Assert
        expect(result, 1500.0);
        verify(() => mockDatabase.getTotalBalance()).called(1);
      });

      test('should return negative balance for expenses only', () async {
        // Arrange
        when(() => mockDatabase.getTotalBalance())
            .thenAnswer((_) async => -500.0);

        // Act
        final result = await movementRepository.getTotalBalance();

        // Assert
        expect(result, -500.0);
      });
    });

    group('getBalanceForPeriod', () {
      test('should return balance for specific period', () async {
        // Arrange
        final start = DateTime(2024);
        final end = DateTime(2024, 1, 31);
        when(() => mockDatabase.getBalanceForPeriod(start, end))
            .thenAnswer((_) async => 2000.0);

        // Act
        final result = await movementRepository.getBalanceForPeriod(start, end);

        // Assert
        expect(result, 2000.0);
        verify(() => mockDatabase.getBalanceForPeriod(start, end)).called(1);
      });
    });

    group('getExpensesByCategory', () {
      test('should return expenses grouped by category', () async {
        // Arrange
        final start = DateTime(2024);
        final end = DateTime(2024, 1, 31);
        final expensesMap = {1: 500.0, 2: 300.0, 3: 200.0};
        when(() => mockDatabase.getExpensesByCategory(start, end))
            .thenAnswer((_) async => expensesMap);

        // Act
        final result =
            await movementRepository.getExpensesByCategory(start, end);

        // Assert
        expect(result.length, 3);
        expect(result[1], 500.0);
        expect(result[2], 300.0);
        expect(result[3], 200.0);
        verify(() => mockDatabase.getExpensesByCategory(start, end)).called(1);
      });

      test('should return empty map when no expenses', () async {
        // Arrange
        final start = DateTime(2024);
        final end = DateTime(2024, 1, 31);
        when(() => mockDatabase.getExpensesByCategory(start, end))
            .thenAnswer((_) async => {});

        // Act
        final result =
            await movementRepository.getExpensesByCategory(start, end);

        // Assert
        expect(result, isEmpty);
      });
    });
  });

  group('MovementRepositoryImpl - Stream Operations', () {
    test('watchAllMovements returns empty stream', () async {
      // Note: Current implementation returns empty stream
      // This test documents the current behavior
      final stream = movementRepository.watchAllMovements();

      await expectLater(stream, emits([]));
    });
  });
}
