// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/monthly_summary_widget.dart';
import '../../widgets/quick_add_floating_button.dart';
import '../../widgets/goal_progress_widget.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoAlDía'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive breakpoints: mobile <600, tablet 600-900, web >900
          final isWide = constraints.maxWidth >= 900;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;

          // Max content width for large screens to prevent overly wide cards
          final maxContentWidth =
              isWide ? 1200.0 : (isTablet ? 800.0 : double.infinity);
          final horizontalPadding = isWide ? 24.0 : 16.0;

          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.isLoading && state.recentMovements.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<DashboardBloc>().add(LoadDashboard()),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(RefreshDashboard());
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: isWide
                          ? _buildWideLayout(context, state)
                          : _buildNarrowLayout(context, state, isTablet),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: QuickAddFloatingButton(
        onPressed: () async {
          final created = await context.push('/add');
          if (!context.mounted || created != true) {
            return;
          }
          context.read<DashboardBloc>().add(LoadDashboard());
        },
      ),
    );
  }

  /// Wide layout (web desktop): 2-column grid with better spacing
  Widget _buildWideLayout(BuildContext context, DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Balance + Monthly Summary side by side
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

        // Savings overview + Pie chart side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSavingsOverview(state),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CategoryPieChart(
                expensesByCategory: state.expensesByCategory,
                categories: state.categories,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Goals and Categories
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.topGoals.isNotEmpty) ...[
              Expanded(child: _buildTopGoalsSection(state)),
              const SizedBox(width: 16),
            ],
            if (state.topExpenseCategories.isNotEmpty) ...[
              Expanded(child: _buildTopCategoriesSection(state)),
              const SizedBox(width: 16),
            ],
          ],
        ),

        // Recent movements (full width)
        if (state.recentMovements.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecentMovements(state.recentMovements, state.categories),
        ],
      ],
    );
  }

  /// Narrow layout (mobile/tablet): stacked with some side-by-side for tablet
  Widget _buildNarrowLayout(
      BuildContext context, DashboardState state, bool isTablet) {
    return Column(
      children: [
        BalanceCard(
          balance: state.totalBalance,
          monthIncome: state.monthIncome,
          monthExpenses: state.monthExpenses,
          isLoading: state.isLoading,
          currencyCode: AppDatabase.currentCurrency,
        ),
        const SizedBox(height: 16),

        // Tablet: side by side, mobile: stacked
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
        else
          Column(
            children: [
              MonthlySummaryWidget(
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
              const SizedBox(height: 16),
              _buildSavingsOverview(state),
            ],
          ),
        const SizedBox(height: 16),

        // Pie chart (full width but constrained)
        SizedBox(
          height: 250,
          child: CategoryPieChart(
            expensesByCategory: state.expensesByCategory,
            categories: state.categories,
          ),
        ),
        const SizedBox(height: 16),

        if (state.topGoals.isNotEmpty) ...[
          _buildTopGoalsSection(state),
          const SizedBox(height: 16),
        ],

        if (state.topExpenseCategories.isNotEmpty) ...[
          _buildTopCategoriesSection(state),
          const SizedBox(height: 16),
        ],

        _buildRecentMovements(state.recentMovements, state.categories),
      ],
    );
  }

  Widget _buildSavingsOverview(DashboardState state) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen de Ahorro',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSavingsRateColor(state.savingsRate)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.savingsRate.toStringAsFixed(1)}% tasa',
                    style: TextStyle(
                      color: _getSavingsRateColor(state.savingsRate),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Ahorro del mes',
                  value: CurrencyFormatter.formatWithSymbol(
                      state.monthSavings, AppDatabase.currentCurrency),
                  color: state.monthSavings >= 0
                      ? AppTheme.budgetSuccessColor
                      : AppTheme.budgetCriticalColor,
                ),
                _StatItem(
                  label: 'Ahorro en metas',
                  value: CurrencyFormatter.formatWithSymbol(
                      state.totalGoalsSaved, AppDatabase.currentCurrency),
                  color: AppTheme.secondaryColor,
                ),
              ],
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Metas Principales',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.push('/goals'),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...state.topGoals.map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GoalProgressLinearWidget(
                          currentAmount: goal.currentAmount,
                          targetAmount: goal.targetAmount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${CurrencyFormatter.formatWithSymbol(goal.currentAmount, AppDatabase.currentCurrency)} / ${CurrencyFormatter.formatNumber(goal.targetAmount, AppDatabase.currentCurrency)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoriesSection(DashboardState state) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorías Más Usadas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.topExpenseCategories.map((cat) {
                final count = state.categoryUsageCount[cat.id] ?? 0;
                return Chip(
                  avatar: Text(cat.icon),
                  label: Text(
                    '${cat.name}: $count',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'No hay movimientos aún',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca el botón + para registrar tu primer gasto',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Movimientos Recientes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.push('/movements'),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movements.take(5).length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final movement = movements[index];
              final category = categories.firstWhere(
                (c) => c.id == movement.categoryId,
                orElse: () => const CategoryEntity(name: 'Sin categoría'),
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(category.icon),
                ),
                title: Text(category.name),
                subtitle: Text(
                  '${movement.merchant ?? ''} ${movement.note ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${movement.type == MovementType.expense ? '-' : ''}${CurrencyFormatter.formatWithSymbol(movement.amount, AppDatabase.currentCurrency)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: movement.type == MovementType.expense
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                onTap: () => context.push('/movement/edit/${movement.id}'),
              );
            },
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
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}
