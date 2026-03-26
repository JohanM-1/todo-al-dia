// lib/presentation/pages/voice/voice_query_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../services/voice_service.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';

class VoiceQueryScreen extends StatefulWidget {
  final VoiceResult voiceResult;

  const VoiceQueryScreen({
    super.key,
    required this.voiceResult,
  });

  @override
  State<VoiceQueryScreen> createState() => _VoiceQueryScreenState();
}

class _VoiceQueryScreenState extends State<VoiceQueryScreen> {
  bool _isLoading = true;
  double _balance = 0;
  double _monthIncome = 0;
  double _monthExpenses = 0;
  double _periodSpending = 0;
  String _periodLabel = 'este mes';
  List<Map<String, dynamic>> _categoryBreakdown = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    context.read<DashboardBloc>().add(LoadDashboard());

    final movementRepo = context.read<MovementRepository>();

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final movements = await movementRepo.getMovementsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    double income = 0;
    double expenses = 0;
    final Map<int, double> categoryTotals = {};

    for (final m in movements) {
      if (m.type.name == 'income') {
        income += m.amount;
      } else {
        expenses += m.amount;
        categoryTotals[m.categoryId] =
            (categoryTotals[m.categoryId] ?? 0) + m.amount;
      }
    }

    final categoryRepo = context.read<CategoryRepository>();
    final categories = await categoryRepo.getExpenseCategories();
    final categoryMap = {for (var c in categories) c.id: c};

    final breakdown = categoryTotals.entries.map((e) {
      final cat = categoryMap[e.key];
      return {
        'category': cat?.name ?? 'Sin categoría',
        'icon': cat?.icon ?? '📁',
        'amount': e.value,
      };
    }).toList()
      ..sort(
          (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    final accountRepo = context.read<AccountRepository>();
    final accounts = await accountRepo.getAllAccounts();
    final totalBalance = accounts.fold<double>(
      0,
      (sum, acc) => sum + acc.balance,
    );

    double periodSpending = expenses;
    String periodLabel = 'este mes';

    final period = widget.voiceResult.slots.period;
    if (period == 'week') {
      periodLabel = 'esta semana';
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weekMovements = await movementRepo.getMovementsByDateRange(
        startOfWeek,
        now,
      );
      periodSpending = weekMovements
          .where((m) => m.type.name == 'expense')
          .fold<double>(0, (sum, m) => sum + m.amount);
    } else if (period == 'year') {
      periodLabel = 'este año';
      final startOfYear = DateTime(now.year);
      final yearMovements = await movementRepo.getMovementsByDateRange(
        startOfYear,
        now,
      );
      periodSpending = yearMovements
          .where((m) => m.type.name == 'expense')
          .fold<double>(0, (sum, m) => sum + m.amount);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _balance = totalBalance;
        _monthIncome = income;
        _monthExpenses = expenses;
        _periodSpending = periodSpending;
        _periodLabel = periodLabel;
        _categoryBreakdown = breakdown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBalanceQuery =
        widget.voiceResult.intent == VoiceIntent.queryBalance;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBalanceQuery ? 'Balance' : 'Gastos'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final isTablet = constraints.maxWidth >= 600;
                final maxWidth =
                    isWide ? 800.0 : (isTablet ? 600.0 : double.infinity);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQueryHeader(theme, isBalanceQuery),
                          const SizedBox(height: 24),
                          if (isBalanceQuery)
                            _buildBalanceCard(theme)
                          else
                            _buildSpendingCard(theme),
                          if (!isBalanceQuery &&
                              _categoryBreakdown.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildCategoryBreakdown(theme),
                          ],
                          const SizedBox(height: 24),
                          _buildActions(theme),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildQueryHeader(ThemeData theme, bool isBalanceQuery) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isBalanceQuery ? Icons.account_balance_wallet : Icons.pie_chart,
              color: theme.colorScheme.onPrimaryContainer,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBalanceQuery
                        ? 'Consulta de balance'
                        : 'Resumen de gastos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '"${widget.voiceResult.transcription}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Balance total',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.formatWithSymbol(
                  _balance, AppDatabase.currentCurrency),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: _balance >= 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Ingresos del mes',
                    CurrencyFormatter.formatWithSymbol(
                        _monthIncome, AppDatabase.currentCurrency),
                    Icons.arrow_upward,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Gastos del mes',
                    CurrencyFormatter.formatWithSymbol(
                        _monthExpenses, AppDatabase.currentCurrency),
                    Icons.arrow_downward,
                    theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Gastos $_periodLabel',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.formatWithSymbol(
                  _periodSpending, AppDatabase.currentCurrency),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Este mes',
                    CurrencyFormatter.formatWithSymbol(
                        _monthExpenses, AppDatabase.currentCurrency),
                    Icons.calendar_month,
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Promedio diario',
                    CurrencyFormatter.formatWithSymbol(
                        (_monthExpenses / 30), AppDatabase.currentCurrency),
                    Icons.trending_down,
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por categoría',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...(_categoryBreakdown.take(5).map((item) {
          final percentage = _monthExpenses > 0
              ? (item['amount'] as double) / _monthExpenses
              : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item['icon'] as String,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item['category'] as String)),
                    Text(
                      CurrencyFormatter.formatWithSymbol(
                          (item['amount'] as double),
                          AppDatabase.currentCurrency),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          );
        })),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/movements'),
            icon: const Icon(Icons.list),
            label: const Text('Ver movimientos'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              context.pop();
              context.read<DashboardBloc>().add(LoadDashboard());
            },
            icon: const Icon(Icons.home),
            label: const Text('Inicio'),
          ),
        ),
      ],
    );
  }
}
