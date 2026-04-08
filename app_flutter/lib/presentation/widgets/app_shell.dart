// lib/presentation/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({
    super.key,
    required this.child,
    required this.state,
  });

  List<_TabConfig> _tabs(AppLocalizations l10n) => [
        _TabConfig(
          path: '/home',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
        ),
        _TabConfig(
          path: '/movements',
          label: l10n.movements,
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long_rounded,
        ),
        _TabConfig(
          path: '/budgets',
          label: l10n.budgets,
          icon: Icons.pie_chart_outline_rounded,
          selectedIcon: Icons.pie_chart_rounded,
        ),
        _TabConfig(
          path: '/goals',
          label: l10n.goals,
          icon: Icons.savings_outlined,
          selectedIcon: Icons.savings_rounded,
        ),
        _TabConfig(
          path: '/settings',
          label: l10n.settings,
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
        ),
      ];

  int _getCurrentIndex(String location, List<_TabConfig> tabs) {
    for (int i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].path)) {
        return i;
      }
    }
    return 0;
  }

  bool _shouldShowMobileLabels(
    BuildContext context,
    double maxWidth,
    List<_TabConfig> tabs,
  ) {
    if (maxWidth <= 0) return false;

    final theme = Theme.of(context);
    final labelStyle = theme.navigationBarTheme.labelTextStyle?.resolve({
          WidgetState.selected,
        }) ??
        theme.textTheme.labelMedium;

    if (labelStyle == null) return true;

    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final widthPerDestination = maxWidth / tabs.length;

    final maxLabelWidth = tabs
        .map(
          (tab) => _measureLabelWidth(
            tab.label,
            style: labelStyle,
            textDirection: textDirection,
            textScaler: textScaler,
          ),
        )
        .reduce((current, next) => current > next ? current : next);

    return widthPerDestination >= maxLabelWidth;
  }

  double _measureLabelWidth(
    String label, {
    required TextStyle style,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _tabs(l10n);
    final currentIndex = _getCurrentIndex(state.uri.toString(), tabs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final shouldShowMobileLabels =
            _shouldShowMobileLabels(context, constraints.maxWidth, tabs);

        if (isMobile) {
          return Scaffold(
            extendBody: true,
            body: child,
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _NavigationBarSurface(
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  labelBehavior: shouldShowMobileLabels
                      ? NavigationDestinationLabelBehavior.alwaysShow
                      : NavigationDestinationLabelBehavior.alwaysHide,
                  onDestinationSelected: (index) =>
                      context.go(tabs[index].path),
                  destinations: tabs
                      .map(
                        (tab) => NavigationDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: tab.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _RailSurface(
                    isTablet: isTablet,
                    currentIndex: currentIndex,
                    tabs: tabs,
                    onDestinationSelected: (index) =>
                        context.go(tabs[index].path),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationBarSurface extends StatelessWidget {
  final Widget child;

  const _NavigationBarSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.80),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}

class _RailSurface extends StatelessWidget {
  final bool isTablet;
  final int currentIndex;
  final List<_TabConfig> tabs;
  final ValueChanged<int> onDestinationSelected;

  const _RailSurface({
    required this.isTablet,
    required this.currentIndex,
    required this.tabs,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: isTablet ? 92 : 248,
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: isDark ? 0.80 : 0.88),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.78),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                isTablet ? 12 : 18, 18, isTablet ? 12 : 18, 8),
            child: isTablet
                ? Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: scheme.onPrimary,
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [scheme.primary, AppTheme.secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TodoAlDía',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.shellSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: currentIndex,
              extended: !isTablet,
              labelType: isTablet
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.none,
              useIndicator: true,
              onDestinationSelected: onDestinationSelected,
              leading: const SizedBox.shrink(),
              destinations: tabs
                  .map(
                    (tab) => NavigationRailDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.selectedIcon),
                      label: Text(tab.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
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
