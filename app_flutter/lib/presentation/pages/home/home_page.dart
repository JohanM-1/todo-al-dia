// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/goal_progress_widget.dart';
import '../../widgets/monthly_summary_widget.dart';
import '../../widgets/quick_add_floating_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<DashboardBloc>().add(RefreshDashboard());
    }
  }

  Future<void> _openQuickAdd() async {
    final created = await context.push('/add');
    if (!mounted || created != true) {
      return;
    }
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inicio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Tu panorama financiero de hoy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;
          final maxContentWidth =
              isWide ? 1240.0 : (isTablet ? 860.0 : double.infinity);
          final horizontalPadding = isWide ? 24.0 : 16.0;

          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: animationsDisabled
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                child: _buildBodyForState(
                  context,
                  state,
                  maxContentWidth: maxContentWidth,
                  horizontalPadding: horizontalPadding,
                  isWide: isWide,
                  isTablet: isTablet,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: QuickAddFloatingButton(
        onPressed: _openQuickAdd,
      ),
    );
  }

  Widget _buildBodyForState(
    BuildContext context,
    DashboardState state, {
    required double maxContentWidth,
    required double horizontalPadding,
    required bool isWide,
    required bool isTablet,
  }) {
    if (state.isLoading && state.recentMovements.isEmpty) {
      return _buildScrollableFrame(
        context,
        maxContentWidth: maxContentWidth,
        horizontalPadding: horizontalPadding,
        child: _buildLoadingState(context),
      );
    }

    if (state.error != null) {
      return _buildScrollableFrame(
        context,
        maxContentWidth: maxContentWidth,
        horizontalPadding: horizontalPadding,
        child: _buildErrorState(context, state.error!),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboard());
      },
      child: _buildScrollableFrame(
        context,
        maxContentWidth: maxContentWidth,
        horizontalPadding: horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(context, state),
            const SizedBox(height: 24),
            if (isWide)
              _buildWideLayout(context, state)
            else
              _buildNarrowLayout(context, state, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableFrame(
    BuildContext context, {
    required double maxContentWidth,
    required double horizontalPadding,
    required Widget child,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding:
          EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 112),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentMonth =
        state.currentMonth > 0 ? state.currentMonth : DateTime.now().month;
    final currentYear =
        state.currentYear > 0 ? state.currentYear : DateTime.now().year;
    final monthLabel = _monthNames[currentMonth - 1];
    final quickStatus =
        state.monthSavings >= 0 ? 'Mes saludable' : 'Mes en revisión';

    return GlassContainer(
      key: const ValueKey('home_hero_header'),
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withValues(alpha: 0.38),
                AppTheme.secondaryColor.withValues(alpha: 0.28),
                scheme.surfaceContainerHighest.withValues(alpha: 0.18),
              ],
              stops: const [0.0, 0.58, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildHeaderChip(
                      context,
                      icon: Icons.auto_graph_rounded,
                      label: quickStatus,
                      color: scheme.primary,
                    ),
                    _buildHeaderChip(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: '$monthLabel $currentYear',
                      color: scheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Una vista clara para decidir mejor, antes de gastar.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.recentMovements.isEmpty
                      ? 'Todavía no hay actividad registrada. Empezá cargando tu primer movimiento y la app te va a devolver contexto real.'
                      : 'Ingresos, gastos y metas en un solo lugar, con prioridad en lo importante y sin ruido visual.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroMetric(
                      label: 'Balance actual',
                      value: CurrencyFormatter.formatWithSymbol(
                        state.totalBalance,
                        AppDatabase.currentCurrency,
                      ),
                      tone: state.totalBalance >= 0
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                    ),
                    _HeroMetric(
                      label: 'Tasa de ahorro',
                      value: '${state.savingsRate.toStringAsFixed(1)}%',
                      tone: _getSavingsRateColor(state.savingsRate),
                    ),
                    _HeroMetric(
                      label: 'Metas activas',
                      value: '${state.topGoals.length}',
                      tone: AppTheme.secondaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openQuickAdd,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Agregar movimiento'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/movements'),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Ver historial'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BalanceCard(
                balance: state.totalBalance,
                monthIncome: state.monthIncome,
                monthExpenses: state.monthExpenses,
                isLoading: state.isLoading,
                currencyCode: AppDatabase.currentCurrency,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MonthlySummaryWidget(
                monthIncome: state.monthIncome,
                monthExpenses: state.monthExpenses,
                monthSavings: state.monthSavings,
                currentMonth: state.currentMonth > 0
                    ? state.currentMonth
                    : DateTime.now().month,
                currentYear: state.currentYear > 0
                    ? state.currentYear
                    : DateTime.now().year,
                isLoading: state.isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSavingsOverview(state)),
            const SizedBox(width: 16),
            Expanded(
                child: CategoryPieChart(
              expensesByCategory: state.expensesByCategory,
              categories: state.categories,
            )),
          ],
        ),
        const SizedBox(height: 16),
        if (state.topGoals.isNotEmpty || state.topExpenseCategories.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.topGoals.isNotEmpty) ...[
                Expanded(child: _buildTopGoalsSection(state)),
                const SizedBox(width: 16),
              ],
              if (state.topExpenseCategories.isNotEmpty)
                Expanded(child: _buildTopCategoriesSection(state)),
            ],
          ),
        if (state.topGoals.isNotEmpty || state.topExpenseCategories.isNotEmpty)
          const SizedBox(height: 16),
        _buildRecentMovements(state.recentMovements, state.categories),
      ],
    );
  }

  Widget _buildNarrowLayout(
      BuildContext context, DashboardState state, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BalanceCard(
          balance: state.totalBalance,
          monthIncome: state.monthIncome,
          monthExpenses: state.monthExpenses,
          isLoading: state.isLoading,
          currencyCode: AppDatabase.currentCurrency,
        ),
        const SizedBox(height: 16),
        if (isTablet)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MonthlySummaryWidget(
                  monthIncome: state.monthIncome,
                  monthExpenses: state.monthExpenses,
                  monthSavings: state.monthSavings,
                  currentMonth: state.currentMonth > 0
                      ? state.currentMonth
                      : DateTime.now().month,
                  currentYear: state.currentYear > 0
                      ? state.currentYear
                      : DateTime.now().year,
                  isLoading: state.isLoading,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildSavingsOverview(state)),
            ],
          )
        else ...[
          MonthlySummaryWidget(
            monthIncome: state.monthIncome,
            monthExpenses: state.monthExpenses,
            monthSavings: state.monthSavings,
            currentMonth: state.currentMonth > 0
                ? state.currentMonth
                : DateTime.now().month,
            currentYear:
                state.currentYear > 0 ? state.currentYear : DateTime.now().year,
            isLoading: state.isLoading,
          ),
          const SizedBox(height: 16),
          _buildSavingsOverview(state),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: CategoryPieChart(
            expensesByCategory: state.expensesByCategory,
            categories: state.categories,
          ),
        ),
        if (state.topGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTopGoalsSection(state),
        ],
        if (state.topExpenseCategories.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTopCategoriesSection(state),
        ],
        const SizedBox(height: 16),
        _buildRecentMovements(state.recentMovements, state.categories),
      ],
    );
  }

  Widget _buildSavingsOverview(DashboardState state) {
    final savingsColor = _getSavingsRateColor(state.savingsRate);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ritmo de ahorro',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Señales rápidas para ajustar hábitos.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: savingsColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${state.savingsRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: savingsColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Ahorro del mes',
                  value: CurrencyFormatter.formatWithSymbol(
                    state.monthSavings,
                    AppDatabase.currentCurrency,
                  ),
                  color: state.monthSavings >= 0
                      ? AppTheme.budgetSuccessColor
                      : AppTheme.budgetCriticalColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: 'En metas',
                  value: CurrencyFormatter.formatWithSymbol(
                    state.totalGoalsSaved,
                    AppDatabase.currentCurrency,
                  ),
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSavingsRateColor(double rate) {
    if (rate >= 20) {
      return AppTheme.budgetSuccessColor;
    }
    if (rate >= 0) {
      return AppTheme.budgetWarningColor;
    }
    return AppTheme.budgetCriticalColor;
  }

  Widget _buildTopGoalsSection(DashboardState state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Metas principales',
            subtitle: 'Seguimiento rápido de lo que más importa.',
            actionLabel: 'Ver todas',
            onAction: () => context.push('/goals'),
          ),
          const SizedBox(height: 16),
          ...state.topGoals.take(3).map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.name,
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${CurrencyFormatter.formatWithSymbol(goal.currentAmount, AppDatabase.currentCurrency)} de ${CurrencyFormatter.formatNumber(goal.targetAmount, AppDatabase.currentCurrency)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              GoalProgressLinearWidget(
                                currentAmount: goal.currentAmount,
                                targetAmount: goal.targetAmount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesSection(DashboardState state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorías frecuentes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Tus patrones más repetidos del mes.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: state.topExpenseCategories.map((cat) {
              final count = state.categoryUsageCount[cat.id] ?? 0;
              return Chip(
                avatar: Text(cat.icon),
                label: Text('${cat.name} · $count'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMovements(
    List<MovementEntity> movements,
    List<CategoryEntity> categories,
  ) {
    if (movements.isEmpty) {
      return GlassCard(
        key: const ValueKey('home_empty_state'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 34,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Todavía no registraste movimientos',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cargá un gasto o ingreso para empezar a ver tendencias, categorías y progreso real.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _openQuickAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Registrar primer movimiento'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/budgets'),
                    icon: const Icon(Icons.pie_chart_rounded),
                    label: const Text('Ver presupuestos'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: _SectionHeader(
              title: 'Movimientos recientes',
              subtitle: 'Los últimos registros para actuar rápido.',
              actionLabel: 'Ver todos',
              onAction: () => context.push('/movements'),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movements.take(5).length,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final movement = movements[index];
              final category = categories.firstWhere(
                (c) => c.id == movement.categoryId,
                orElse: () => const CategoryEntity(name: 'Sin categoría'),
              );
              final amountColor = movement.type == MovementType.expense
                  ? AppTheme.expenseColor
                  : AppTheme.incomeColor;
              final details = [movement.merchant, movement.note]
                  .where((value) => value != null && value.trim().isNotEmpty)
                  .join(' · ');

              return Material(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(category.icon)),
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    details.isEmpty ? 'Sin detalle adicional' : details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${movement.type == MovementType.expense ? '-' : '+'}${CurrencyFormatter.formatWithSymbol(movement.amount, AppDatabase.currentCurrency)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                        ),
                  ),
                  onTap: () => context.push('/movement/edit/${movement.id}'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LoadingHero(),
        SizedBox(height: 20),
        _LoadingGrid(),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);

    return GlassCard(
      key: const ValueKey('home_error_state'),
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar tu resumen',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Reintentá ahora. Si el problema sigue, revisá la configuración o volvé en unos segundos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<DashboardBloc>().add(LoadDashboard()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Ir a ajustes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _HeroMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _LoadingHero extends StatelessWidget {
  const _LoadingHero();

  @override
  Widget build(BuildContext context) {
    return const GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingBar(width: 120, height: 28),
          SizedBox(height: 16),
          _LoadingBar(width: 300, height: 40),
          SizedBox(height: 10),
          _LoadingBar(width: double.infinity, height: 16),
          SizedBox(height: 8),
          _LoadingBar(width: 260, height: 16),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _LoadingCard()),
              SizedBox(width: 12),
              Expanded(child: _LoadingCard()),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: _LoadingPanel(height: 230)),
            SizedBox(width: 16),
            Expanded(child: _LoadingPanel(height: 230)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _LoadingPanel(height: 220)),
            SizedBox(width: 16),
            Expanded(child: _LoadingPanel(height: 220)),
          ],
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  final double height;

  const _LoadingPanel({required this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(height: height),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _LoadingBar(width: double.infinity, height: 92);
  }
}

class _LoadingBar extends StatelessWidget {
  final double width;
  final double height;

  const _LoadingBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

const _monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];
