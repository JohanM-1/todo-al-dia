// lib/presentation/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AppShell provides the navigation for the main app.
/// Uses go_router's StatefulShellRoute for preserving navigation state.
/// Implements responsive navigation: bottom nav for mobile, rail for tablet/web.
class AppShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({
    super.key,
    required this.child,
    required this.state,
  });

  static const _tabs = [
    _TabConfig(
      path: '/home',
      label: 'Inicio',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _TabConfig(
      path: '/movements',
      label: 'Movimientos',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    _TabConfig(
      path: '/budgets',
      label: 'Presupuestos',
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
    ),
    _TabConfig(
      path: '/goals',
      label: 'Metas',
      icon: Icons.savings_outlined,
      selectedIcon: Icons.savings,
    ),
    _TabConfig(
      path: '/settings',
      label: 'Ajustes',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  int _getCurrentIndex(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(state.uri.toString());

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoints: <600 mobile (bottom nav), 600-900 tablet (rail), >900 web (rail expanded)
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        if (isMobile) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (index) {
                context.go(_tabs[index].path);
              },
              destinations: _tabs
                  .map((tab) => NavigationDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(tab.selectedIcon),
                        label: tab.label,
                      ))
                  .toList(),
            ),
          );
        }

        // Tablet and Web: use NavigationRail
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: currentIndex,
                extended: isTablet ? false : true,
                minWidth: 72,
                minExtendedWidth: 200,
                labelType: isTablet
                    ? NavigationRailLabelType.all
                    : NavigationRailLabelType.none,
                onDestinationSelected: (index) {
                  context.go(_tabs[index].path);
                },
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isTablet
                      ? Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Text(
                          'TodoAlDía',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                ),
                destinations: _tabs
                    .map((tab) => NavigationRailDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: Text(tab.label),
                        ))
                    .toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _TabConfig {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _TabConfig({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
