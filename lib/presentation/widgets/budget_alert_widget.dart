// lib/presentation/widgets/budget_alert_widget.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database/app_database.dart';
import '../bloc/budget/budget_state.dart';

class BudgetAlertWidget extends StatelessWidget {
  final BudgetAlert alert;

  const BudgetAlertWidget({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final level = alert.level;
    final percentage = alert.percentage;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;

    if (level == BudgetAlertLevel.exceeded) {
      backgroundColor = AppTheme.budgetCriticalColor;
      textColor = Colors.white;
      icon = Icons.warning_rounded;
      title = '¡Presupuesto Excedido!';
      subtitle =
          'Has gastado ${CurrencyFormatter.formatWithSymbol(alert.spent, AppDatabase.currentCurrency)} '
          'de ${CurrencyFormatter.formatWithSymbol(alert.budget.limit, AppDatabase.currentCurrency)}';
    } else if (level == BudgetAlertLevel.warning) {
      backgroundColor = AppTheme.budgetWarningColor;
      textColor = Colors.white;
      icon = Icons.error_outline_rounded;
      title = '¡Casi llegas al límite!';
      subtitle =
          'Has usado el ${percentage.toStringAsFixed(0)}% de tu presupuesto';
    } else {
      // Normal - shouldn't be shown normally
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
