// lib/presentation/widgets/monthly_summary_widget.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database/app_database.dart';

class MonthlySummaryWidget extends StatelessWidget {
  final double monthIncome;
  final double monthExpenses;
  final double monthSavings;
  final int currentMonth;
  final int currentYear;
  final bool isLoading;

  const MonthlySummaryWidget({
    super.key,
    required this.monthIncome,
    required this.monthExpenses,
    required this.monthSavings,
    required this.currentMonth,
    required this.currentYear,
    this.isLoading = false,
  });

  static const _monthNames = [
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = _monthNames[currentMonth - 1];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen $monthName $currentYear',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Ingresos',
                      monthIncome,
                      AppTheme.incomeColor,
                      Icons.arrow_upward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Gastos',
                      monthExpenses,
                      AppTheme.expenseColor,
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Ahorro',
                      monthSavings,
                      monthSavings >= 0
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                      monthSavings >= 0 ? Icons.savings : Icons.warning,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.formatWithSymbol(
                amount, AppDatabase.currentCurrency),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
