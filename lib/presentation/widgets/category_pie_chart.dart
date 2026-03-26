// lib/presentation/widgets/category_pie_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/entities.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<int, double> expensesByCategory;
  final List<CategoryEntity> categories;

  const CategoryPieChart({
    super.key,
    required this.expensesByCategory,
    required this.categories,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.expensesByCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No hay gastos este mes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gastos por Categoría',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildSections(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.expensesByCategory.values.fold(0.0, (a, b) => a + b);
    final entries = widget.expensesByCategory.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryId = entry.value.key;
      final amount = entry.value.value;
      final percentage = (amount / total * 100);
      final isTouched = index == touchedIndex;

      // Find category name
      final category = widget.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => const CategoryEntity(name: 'Otros'),
      );

      return PieChartSectionData(
        color: AppTheme.categoryColors[
            category.colorIndex % AppTheme.categoryColors.length],
        value: amount,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.expensesByCategory.entries.map((entry) {
        final category = widget.categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => const CategoryEntity(name: 'Otros'),
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.categoryColors[
                    category.colorIndex % AppTheme.categoryColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${category.icon} ${category.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}
