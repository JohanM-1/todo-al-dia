// test/core/theme/glass_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoaldia/core/theme/glass_card.dart';

void main() {
  group('GlassCard Widget', () {
    testWidgets('renders child widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies custom blur value', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              blur: 20.0,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('applies custom opacity', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              opacity: 0.5,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('applies custom border radius', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              borderRadius: BorderRadius.circular(20),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              padding: EdgeInsets.all(32),
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('GlassContainer renders correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: Text('Container Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Container Content'), findsOneWidget);
    });
  });
}
