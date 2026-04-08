// lib/presentation/widgets/balance_card.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/glass_card.dart';
import '../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double monthIncome;
  final double monthExpenses;
  final bool isLoading;
  final String currencyCode;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.monthIncome,
    required this.monthExpenses,
    this.isLoading = false,
    this.currencyCode = 'COP',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final balanceColor =
        balance >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor;

    return GlassCard(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance total',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vista rápida de cómo viene este mes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const SizedBox(
              height: 56,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(),
              ),
            )
          else
            AnimatedDefaultTextStyle(
              duration: _motionDuration(context),
              style: theme.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: balanceColor,
                letterSpacing: -1,
              ),
              child: Text(balance.toCurrencyCode(currencyCode)),
            ),
          const SizedBox(height: 8),
          Text(
            balance >= 0
                ? 'Estás cerrando el mes con margen positivo.'
                : 'Tus gastos vienen por encima del ingreso disponible.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: 'Ingresos',
                  amount: monthIncome,
                  color: AppTheme.incomeColor,
                  icon: Icons.arrow_downward_rounded,
                  accent: '+',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: 'Gastos',
                  amount: monthExpenses,
                  color: AppTheme.expenseColor,
                  icon: Icons.arrow_upward_rounded,
                  accent: '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Duration _motionDuration(BuildContext context) {
    return MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
    required String accent,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                accent,
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount.toCurrencyCode(currencyCode),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
