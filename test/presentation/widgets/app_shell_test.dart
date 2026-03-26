// test/presentation/widgets/app_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:todoaldia/presentation/widgets/app_shell.dart';

void main() {
  group('AppShell Responsive Navigation', () {
    GoRouter buildRouter() {
      return GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AppShell(
                state: state,
                child: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const Text('Home'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/movements',
                    builder: (context, state) => const Text('Movements'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/budgets',
                    builder: (context, state) => const Text('Budgets'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/goals',
                    builder: (context, state) => const Text('Goals'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/settings',
                    builder: (context, state) => const Text('Settings'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    testWidgets('uses bottom navigation on mobile widths', (tester) async {
      // Arrange
      final router = buildRouter();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Act
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('uses compact rail on tablet widths', (tester) async {
      // Arrange
      final router = buildRouter();
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Act
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
    });

    testWidgets('uses extended rail on desktop widths', (tester) async {
      // Arrange
      final router = buildRouter();
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Act
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
      expect(find.text('TodoAlDía'), findsOneWidget);
    });
  });
}
