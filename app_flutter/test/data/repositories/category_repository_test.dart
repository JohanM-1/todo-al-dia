import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaldia/data/database/app_database.dart';
import 'package:todoaldia/data/repositories/repository_impl.dart';
import 'package:todoaldia/domain/entities/entities.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late CategoryRepositoryImpl categoryRepository;
  late MockAppDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockAppDatabase();
    categoryRepository = CategoryRepositoryImpl(mockDatabase);
  });

  group('CategoryRepositoryImpl', () {
    test('normalizes legacy category names when reading', () async {
      when(() => mockDatabase.getExpenseCategories()).thenAnswer(
        (_) async => [
          {
            'id': 1,
            'name': '🍔 Comida',
            'icon': '🍔',
            'color_index': 0,
            'is_system': 1,
            'is_income': 0,
          },
        ],
      );

      final result = await categoryRepository.getExpenseCategories();

      expect(result, hasLength(1));
      expect(result.first.name, 'Comida');
      expect(result.first.icon, '🍔');
      verify(() => mockDatabase.getExpenseCategories()).called(1);
    });

    test('normalizes duplicated icon before creating categories', () async {
      when(() => mockDatabase.insertCategory(any())).thenAnswer((_) async => 1);

      await categoryRepository.createCategory(
        const CategoryEntity(name: '🍔 Comida', icon: '🍔'),
      );

      verify(
        () => mockDatabase.insertCategory(
          any(
            that: isA<Map<String, dynamic>>()
                .having((map) => map['name'], 'name', 'Comida')
                .having((map) => map['icon'], 'icon', '🍔'),
          ),
        ),
      ).called(1);
    });

    test('normalizes duplicated icon before updating categories', () async {
      when(() => mockDatabase.getAllCategories()).thenAnswer(
        (_) async => [
          {
            'id': 7,
            'name': '🍔 Comida',
            'icon': '🍔',
            'color_index': 0,
            'is_system': 0,
            'is_income': 0,
            'created_at': '2024-01-15T00:00:00.000',
          },
        ],
      );
      when(() => mockDatabase.updateCategory(7, any()))
          .thenAnswer((_) async => 7);

      final result = await categoryRepository.updateCategory(
        const CategoryEntity(id: 7, name: '🍔 Comida', icon: '🍔'),
      );

      expect(result, isTrue);
      verify(
        () => mockDatabase.updateCategory(
          7,
          any(
            that: isA<Map<String, dynamic>>()
                .having((map) => map['name'], 'name', 'Comida')
                .having((map) => map['icon'], 'icon', '🍔'),
          ),
        ),
      ).called(1);
    });

    test('removes previously persisted icon when updating category icon',
        () async {
      when(() => mockDatabase.getAllCategories()).thenAnswer(
        (_) async => [
          {
            'id': 7,
            'name': '🍔 Comida',
            'icon': '🍔',
            'color_index': 0,
            'is_system': 0,
            'is_income': 0,
            'created_at': '2024-01-15T00:00:00.000',
          },
        ],
      );
      when(() => mockDatabase.updateCategory(7, any()))
          .thenAnswer((_) async => 7);

      final result = await categoryRepository.updateCategory(
        const CategoryEntity(id: 7, name: '🍔 Comida', icon: '🍕'),
      );

      expect(result, isTrue);
      verify(
        () => mockDatabase.updateCategory(
          7,
          any(
            that: isA<Map<String, dynamic>>()
                .having((map) => map['name'], 'name', 'Comida')
                .having((map) => map['icon'], 'icon', '🍕'),
          ),
        ),
      ).called(1);
    });
  });
}
