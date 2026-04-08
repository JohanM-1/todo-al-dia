// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/budgets/budget_form_page.dart';
import '../../presentation/pages/budgets/budgets_page.dart';
import '../../presentation/pages/goals/goal_form_page.dart';
import '../../presentation/pages/goals/goals_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/movements/add_movement_page.dart';
import '../../presentation/pages/movements/movements_page.dart';
import '../../presentation/pages/movements/movement_form_page.dart';
import '../../presentation/pages/movements/movement_edit_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/settings/category_management_page.dart';
import '../../presentation/pages/settings/export_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/voice/voice_confirmation_screen.dart';
import '../../presentation/pages/voice/voice_query_screen.dart';
import '../../presentation/widgets/app_shell.dart';
import '../../services/voice_service.dart';

Widget _buildInvalidRoutePage(BuildContext context, String message) {
  return Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// App router with bottom navigation shell.
/// Uses StatefulShellRoute to preserve navigation state across tab switches.
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // Onboarding route (outside shell)
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // Voice routes (outside shell - full screen)
    GoRoute(
      path: '/voice/confirmation',
      builder: (context, state) {
        final voiceResult = state.extra as VoiceResult;
        return VoiceConfirmationScreen(voiceResult: voiceResult);
      },
    ),
    GoRoute(
      path: '/voice/query',
      builder: (context, state) {
        final voiceResult = state.extra as VoiceResult;
        return VoiceQueryScreen(voiceResult: voiceResult);
      },
    ),

    // Shell route with bottom navigation for main app tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(
          state: state,
          child: navigationShell,
        );
      },
      branches: [
        // Branch 0: Home / Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Branch 1: Movements
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/movements',
              builder: (context, state) => const MovementsPage(),
            ),
          ],
        ),
        // Branch 2: Budgets
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/budgets',
              builder: (context, state) => const BudgetsPage(),
            ),
          ],
        ),
        // Branch 3: Goals
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const GoalsPage(),
            ),
          ],
        ),
        // Branch 4: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),

    // Form routes (outside shell - push navigation)
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddMovementPage(),
    ),
    GoRoute(
      path: '/movement/form',
      builder: (context, state) => const MovementFormPage(),
    ),
    GoRoute(
      path: '/movement/edit/:id',
      builder: (context, state) {
        final idParam = state.pathParameters['id'] ?? '';
        final id = int.tryParse(idParam);
        if (id == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID de movimiento inválido')),
            );
          });
          return _buildInvalidRoutePage(
              context, 'No pudimos abrir este movimiento.');
        }
        return MovementEditPage(movementId: id);
      },
    ),
    GoRoute(
      path: '/budget/add',
      builder: (context, state) => const BudgetFormPage(),
    ),
    GoRoute(
      path: '/budget/edit/:id',
      builder: (context, state) {
        final idParam = state.pathParameters['id'] ?? '';
        final id = int.tryParse(idParam);
        if (id == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID de presupuesto inválido')),
            );
          });
          return _buildInvalidRoutePage(
            context,
            'No pudimos abrir este presupuesto.',
          );
        }
        return BudgetFormPage(budgetId: id);
      },
    ),
    GoRoute(
      path: '/goal/add',
      builder: (context, state) => const GoalFormPage(),
    ),
    GoRoute(
      path: '/goal/edit/:id',
      builder: (context, state) {
        final idParam = state.pathParameters['id'] ?? '';
        final id = int.tryParse(idParam);
        if (id == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID de meta inválido')),
            );
          });
          return _buildInvalidRoutePage(context, 'No pudimos abrir esta meta.');
        }
        return GoalFormPage(goalId: id);
      },
    ),
    GoRoute(
      path: '/settings/export',
      builder: (context, state) => const ExportPage(),
    ),
    GoRoute(
      path: '/settings/categories',
      builder: (context, state) => const CategoryManagementPage(),
    ),
  ],
);
