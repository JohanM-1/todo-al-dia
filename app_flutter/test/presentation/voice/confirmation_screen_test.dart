// test/presentation/voice/confirmation_screen_test.dart
//
// Widget tests for VoiceConfirmationScreen.
// Mocks BLoC and repositories to test UI in isolation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaldia/presentation/pages/voice/voice_confirmation_screen.dart';
import 'package:todoaldia/presentation/bloc/movement/movement_bloc.dart';
import 'package:todoaldia/presentation/bloc/movement/movement_event.dart';
import 'package:todoaldia/presentation/bloc/movement/movement_state.dart';
import 'package:todoaldia/domain/repositories/repositories.dart';
import 'package:todoaldia/domain/entities/entities.dart';
import 'package:todoaldia/services/voice_service.dart';

// Mocks
class MockMovementBloc extends Mock implements MovementBloc {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class FakeMovementEvent extends Fake implements MovementEvent {}

void main() {
  late MockMovementBloc mockMovementBloc;
  late MockCategoryRepository mockCategoryRepository;
  late MockAccountRepository mockAccountRepository;

  // Test fixtures
  const testCategory = CategoryEntity(
    id: 1,
    name: '🍔 Comida',
    icon: '🍔',
    isSystem: true,
  );

  setUpAll(() {
    registerFallbackValue(FakeMovementEvent());
  });

  setUp(() {
    mockMovementBloc = MockMovementBloc();
    mockCategoryRepository = MockCategoryRepository();
    mockAccountRepository = MockAccountRepository();

    // Default stub states
    when(() => mockMovementBloc.state).thenReturn(const MovementState());
    when(() => mockMovementBloc.stream).thenAnswer(
      (_) => Stream.value(const MovementState()),
    );

    // Default stub for CreateMovement event
    when(() => mockMovementBloc.add(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest({
    required VoiceResult voiceResult,
    int? accountId,
  }) {
    final router = GoRouter(
      initialLocation: '/voice/confirmation',
      routes: [
        GoRoute(
          path: '/voice/confirmation',
          builder: (context, state) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider<MovementBloc>.value(value: mockMovementBloc),
              RepositoryProvider<CategoryRepository>.value(
                value: mockCategoryRepository,
              ),
              RepositoryProvider<AccountRepository>.value(
                value: mockAccountRepository,
              ),
            ],
            child: Scaffold(
              body: VoiceConfirmationScreen(
                voiceResult: voiceResult,
                accountId: accountId,
              ),
            ),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('VoiceConfirmationScreen', () {
    group('Initial Render', () {
      testWidgets('should show app bar with Confirmar title', (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 500 en comida',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(amount: '500', category: 'Comida'),
          confidence: 0.9,
        );

        // Stub repository calls
        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(id: 1, name: '🍔 Comida', icon: '🍔'),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        expect(find.text('Confirmar'), findsWidgets);
        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('Voice Result Display', () {
      testWidgets('should display expense summary card for expense intent',
          (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 5000 en supermercado',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(
            amount: '5000',
            category: 'Supermercado',
          ),
          confidence: 0.9,
        );

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(
                    id: 1,
                    name: '🛒 Supermercado',
                    icon: '🛒',
                  ),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        // Should show intent description
        expect(find.text('Registrar gasto'), findsOneWidget);
        // Should show transcription
        expect(find.text('"Gasté 5000 en supermercado"'), findsOneWidget);
      });

      testWidgets('should display income summary card for income intent',
          (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Cobré 50000 de sueldo',
          intent: VoiceIntent.createIncome,
          slots: VoiceSlot(
            amount: '50000',
            category: 'Salario',
          ),
          confidence: 0.9,
        );

        when(() => mockCategoryRepository.getIncomeCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(id: 1, name: '💰 Salario', icon: '💰'),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        expect(find.text('Registrar ingreso'), findsOneWidget);
      });
    });

    group('Form Fields', () {
      testWidgets('should show amount field with extracted amount',
          (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 1500',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(amount: '1500'),
          confidence: 0.9,
        );

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(id: 1, name: '🍔 Comida', icon: '🍔'),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        expect(find.text('Monto'), findsOneWidget);
        expect(find.text('\$ '), findsOneWidget);
      });

      testWidgets('should show account dropdown', (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 500',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(amount: '500'),
          confidence: 0.9,
        );

        final accounts = [
          AccountEntity(
            id: 1,
            name: 'Efectivo',
            createdAt: DateTime.now(),
          ),
          AccountEntity(
            id: 2,
            name: 'Banco',
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(id: 1, name: '🍔 Comida', icon: '🍔'),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => accounts);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        expect(find.text('Cuenta'), findsOneWidget);
        expect(find.text('Efectivo'), findsOneWidget);
      });

      testWidgets('should show category dropdown', (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 500',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(amount: '500'),
          confidence: 0.9,
        );

        final categories = [
          const CategoryEntity(id: 1, name: '🍔 Comida', icon: '🍔'),
          const CategoryEntity(id: 2, name: '🚗 Transporte', icon: '🚗'),
        ];

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => categories);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        expect(find.text('Categoría'), findsOneWidget);
      });

      testWidgets('should show date picker field', (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 500',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(amount: '500'),
          confidence: 0.9,
        );

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(id: 1, name: '🍔 Comida', icon: '🍔'),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        expect(find.text('Fecha'), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('should show payment method field when provided',
          (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 500 con débito',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(
            amount: '500',
            paymentMethod: 'débito',
          ),
          confidence: 0.9,
        );

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(id: 1, name: '🍔 Comida', icon: '🍔'),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        expect(find.text('Método de pago'), findsOneWidget);
      });
    });

    group('Form Actions', () {
      testWidgets('should have Confirm button', (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 500',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(amount: '500'),
          confidence: 0.9,
        );

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [
                  const CategoryEntity(id: 1, name: '🍔 Comida', icon: '🍔'),
                ]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => [
                  AccountEntity(
                    id: 1,
                    name: 'Efectivo',
                    createdAt: DateTime.now(),
                  ),
                ]);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        // "Confirmar" appears twice: in AppBar title and on button
        expect(find.text('Confirmar'), findsNWidgets(2));
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      // Note: Close button tests require a parent route in navigation stack
      // These are integration-level tests, not widget-level tests
    });

    group('Error Handling', () {
      testWidgets('should handle empty accounts list gracefully',
          (tester) async {
        const voiceResult = VoiceResult(
          transcription: 'Gasté 500',
          intent: VoiceIntent.createExpense,
          slots: VoiceSlot(amount: '500'),
          confidence: 0.9,
        );

        when(() => mockCategoryRepository.getExpenseCategories())
            .thenAnswer((_) async => [testCategory]);
        when(() => mockAccountRepository.getAllAccounts())
            .thenAnswer((_) async => []);

        await tester
            .pumpWidget(createWidgetUnderTest(voiceResult: voiceResult));
        await tester.pumpAndSettle();

        // Account dropdown should be visible (empty selection)
        expect(find.text('Cuenta'), findsOneWidget);
        expect(find.text('Categoría'), findsOneWidget);
      });
    });
  });
}
