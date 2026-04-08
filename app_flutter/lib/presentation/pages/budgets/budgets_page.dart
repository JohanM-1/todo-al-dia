// lib/presentation/pages/budgets/budgets_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_event.dart';
import '../../bloc/budget/budget_state.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../widgets/budget_alert_widget.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/page_hero_card.dart';
import '../../widgets/quick_add_floating_button.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    context.read<BudgetBloc>().add(
          LoadBudgetsForPeriod(month: _selectedMonth, year: _selectedYear),
        );
  }

  Future<void> _selectPeriod() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked.month;
        _selectedYear = picked.year;
      });
      _loadBudgets();
    }
  }

  String get _periodLabel {
    const months = [
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
      'Diciembre'
    ];
    return '${months[_selectedMonth - 1]} $_selectedYear';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final horizontalPadding = isWide ? 24.0 : 16.0;
        final maxContentWidth =
            isWide ? 1000.0 : (isTablet ? 600.0 : double.infinity);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Presupuestos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _selectPeriod,
                tooltip: 'Cambiar período',
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 8),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: BlocConsumer<BudgetBloc, BudgetState>(
                  listener: (context, state) {
                    if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.error}')),
                      );
                    }
                    if (state.successMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.successMessage!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeroCard(
                          eyebrow: 'Presupuesto mensual',
                          title: 'Controlá tus límites antes de pasarte.',
                          subtitle:
                              'Seguí el gasto por categoría, detectá alertas y redistribuí presupuesto con menos fricción visual.',
                          icon: Icons.pie_chart_rounded,
                          actions: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await context.push('/budget/add');
                                _loadBudgets();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Nuevo presupuesto'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _selectPeriod,
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: const Text('Cambiar período'),
                            ),
                          ],
                          footer: [
                            HeroBadge(
                              label: _periodLabel,
                              color: Theme.of(context).colorScheme.primary,
                              icon: Icons.event_available_rounded,
                            ),
                            HeroBadge(
                              label:
                                  '${state.budgets.length} categorías activas',
                              color: AppTheme.secondaryColor,
                              icon: Icons.category_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPeriodHeader(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildBody(state)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          floatingActionButton: QuickAddFloatingButton(
            isExtended: !isTablet,
            label: 'Nuevo presupuesto',
            onPressed: () async {
              await context.push('/budget/add');
              _loadBudgets();
            },
          ),
        );
      },
    );
  }

  Widget _buildPeriodHeader() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _periodLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BudgetState state) {
    if (state.isLoading && state.budgets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show budget alerts for warning/exceeded budgets
    final alertBudgets =
        state.alerts.where((a) => a.level != BudgetAlertLevel.normal).toList();

    if (state.budgets.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBudgets(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card
          _buildSummaryCard(state),
          const SizedBox(height: 16),
          if (alertBudgets.isNotEmpty) ...[
            ...alertBudgets.map((alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BudgetAlertWidget(alert: alert),
                )),
            const SizedBox(height: 8),
          ],
          ...state.budgetsWithProgress.map((budgetWithProgress) {
            return _BudgetCard(
              budgetWithProgress: budgetWithProgress,
              onTap: () async {
                await context
                    .push('/budget/edit/${budgetWithProgress.budget.id}');
                _loadBudgets();
              },
              onDelete: () => _deleteBudget(budgetWithProgress.budget),
              onMove: () => _showMoveDialog(budgetWithProgress),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BudgetState state) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;

                return Wrap(
                  alignment: compact
                      ? WrapAlignment.start
                      : WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: compact ? constraints.maxWidth : null,
                      child: _SummaryItem(
                        label: 'Presupuesto',
                        value: CurrencyFormatter.formatWithSymbol(
                            state.totalBudget, AppDatabase.currentCurrency),
                        color: Colors.blue,
                        alignStart: compact,
                      ),
                    ),
                    SizedBox(
                      width: compact ? constraints.maxWidth : null,
                      child: _SummaryItem(
                        label: 'Gastado',
                        value: CurrencyFormatter.formatWithSymbol(
                            state.totalSpent, AppDatabase.currentCurrency),
                        color: AppTheme.budgetWarningColor,
                        alignStart: compact,
                      ),
                    ),
                    SizedBox(
                      width: compact ? constraints.maxWidth : null,
                      child: _SummaryItem(
                        label: 'Restante',
                        value: CurrencyFormatter.formatWithSymbol(
                            state.totalRemaining, AppDatabase.currentCurrency),
                        color: AppTheme.budgetSuccessColor,
                        alignStart: compact,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.totalBudget > 0
                    ? (state.totalSpent / state.totalBudget).clamp(0.0, 1.0)
                    : 0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  state.totalSpent > state.totalBudget
                      ? AppTheme.budgetCriticalColor
                      : AppTheme.budgetSuccessColor,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMoveDialog(BudgetWithProgress budgetWithProgress) async {
    final categoryRepo = context.read<CategoryRepository>();
    final categories = await categoryRepo.getExpenseCategories();

    if (!mounted || categories.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Se necesitan al menos 2 categorías con presupuestos')),
        );
      }
      return;
    }

    final otherCategories = categories
        .where((c) => c.id != budgetWithProgress.budget.categoryId)
        .toList();

    final currentBudget = budgetWithProgress.budget;
    final fromCategory = budgetWithProgress.category;

    CategoryEntity? selectedToCategory;
    final amountController = TextEditingController(
      text: CurrencyFormatter.formatNumber(
        budgetWithProgress.remaining,
        AppDatabase.currentCurrency,
      ),
    );

    selectedToCategory = await showDialog<CategoryEntity>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mover Presupuesto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desde: ${fromCategory?.name ?? "Categoría"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Disponible: ${CurrencyFormatter.formatWithSymbol(budgetWithProgress.remaining, AppDatabase.currentCurrency)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const Text('Hacia:'),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return DropdownButtonFormField<CategoryEntity>(
                  initialValue: selectedToCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: otherCategories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.icon} ${c.name}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedToCategory = value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            CurrencyTextField(
              controller: amountController,
              currencyCode: AppDatabase.currentCurrency,
              labelText: 'Monto a mover',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (selectedToCategory != null) {
                Navigator.pop(context, selectedToCategory);
              }
            },
            child: const Text('Mover'),
          ),
        ],
      ),
    );

    if (selectedToCategory != null && mounted) {
      final amount = CurrencyFormatter.parse(
        amountController.text,
        AppDatabase.currentCurrency,
      );
      if (amount != null &&
          amount > 0 &&
          amount <= budgetWithProgress.remaining) {
        context.read<BudgetBloc>().add(MoveBudgetAmount(
              fromCategoryId: currentBudget.categoryId,
              toCategoryId: selectedToCategory!.id!,
              amount: amount,
            ));
        // Refresh dashboard after move
        context.read<DashboardBloc>().add(LoadDashboard());
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monto inválido')),
        );
      }
    }

    amountController.dispose();
  }

  Widget _buildEmptyState() {
    return EmptyStateCard(
      icon: Icons.pie_chart_outline_rounded,
      title: 'Todavía no hay presupuestos',
      subtitle:
          'Creá límites por categoría para que la app te avise ANTES de que el mes se te vaya de las manos.',
      action: ElevatedButton.icon(
        onPressed: () => context.push('/budget/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Crear primer presupuesto'),
      ),
    );
  }

  Future<void> _deleteBudget(BudgetEntity budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Presupuesto'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este presupuesto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && budget.id != null) {
      if (!mounted) {
        return;
      }

      context.read<BudgetBloc>().add(DeleteBudget(id: budget.id!));
      // Refresh dashboard after delete
      context.read<DashboardBloc>().add(LoadDashboard());
    }
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetWithProgress budgetWithProgress;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  const _BudgetCard({
    required this.budgetWithProgress,
    required this.onTap,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final budget = budgetWithProgress.budget;
    final spent = budgetWithProgress.spent;
    final remaining = budgetWithProgress.remaining;
    final percentage = budgetWithProgress.percentage;
    final category = budgetWithProgress.category;
    Color progressColor;
    if (percentage >= 100) {
      progressColor = AppTheme.budgetCriticalColor;
    } else if (percentage >= 80) {
      progressColor = AppTheme.budgetWarningColor;
    } else {
      progressColor = AppTheme.budgetSuccessColor;
    }

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      category?.name ?? 'Categoría ${budget.categoryId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, size: 20),
                        onPressed: onMove,
                        tooltip: 'Mover presupuesto',
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: onDelete,
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 4,
                children: [
                  Text(
                    '${CurrencyFormatter.formatWithSymbol(spent, AppDatabase.currentCurrency)} gastado',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${CurrencyFormatter.formatWithSymbol(remaining, AppDatabase.currentCurrency)} restante',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Límite: ${CurrencyFormatter.formatWithSymbol(budget.limit, AppDatabase.currentCurrency)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              if (percentage >= 100)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.budgetCriticalColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '¡Presupuesto excedido!',
                      style: TextStyle(
                        color: AppTheme.budgetCriticalColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else if (percentage >= 80)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.budgetWarningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '¡Casi llegas al límite!',
                      style: TextStyle(
                        color: AppTheme.budgetWarningColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool alignStart;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.alignStart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
