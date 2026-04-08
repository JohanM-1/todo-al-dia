// lib/presentation/widgets/goal_progress_widget.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database/app_database.dart';

class GoalProgressWidget extends StatelessWidget {
  final double currentAmount;
  final double targetAmount;
  final double size;

  const GoalProgressWidget({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
    this.size = 100,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = _getProgressColor();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: size * 0.08,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: size * 0.08,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(progressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    final percentage = progress * 100;
    if (percentage >= 100) {
      return AppTheme.budgetSuccessColor;
    } else if (percentage >= 80) {
      return AppTheme.budgetWarningColor;
    } else if (percentage >= 50) {
      return Colors.blue;
    } else {
      return AppTheme.secondaryColor;
    }
  }
}

class GoalProgressLinearWidget extends StatelessWidget {
  final double currentAmount;
  final double targetAmount;
  final double height;

  const GoalProgressLinearWidget({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
    this.height = 8,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  Color get _progressColor {
    final percentage = progress * 100;
    if (percentage >= 100) {
      return AppTheme.budgetSuccessColor;
    } else if (percentage >= 80) {
      return AppTheme.budgetWarningColor;
    } else if (percentage >= 50) {
      return Colors.blue;
    } else {
      return AppTheme.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(_progressColor),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CurrencyFormatter.formatWithSymbol(
                  currentAmount, AppDatabase.currentCurrency),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _progressColor,
                  ),
            ),
            Text(
              CurrencyFormatter.formatWithSymbol(
                  targetAmount, AppDatabase.currentCurrency),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
