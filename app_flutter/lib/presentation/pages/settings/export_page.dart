// lib/presentation/pages/settings/export_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../services/export_service.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final ExportService _exportService = ExportService();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;
  String? _exportResult;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = isWide ? 24.0 : 16.0;
        final maxContentWidth = isWide ? 600.0 : double.infinity;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Exportar'),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Exportar a CSV',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Descarga todos tus movimientos en un archivo CSV '
                              'que puedes abrir en Excel o Google Sheets.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Desde'),
                            subtitle: Text(_formatDate(_startDate)),
                            onTap: () => _selectDate(isStart: true),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Hasta'),
                            subtitle: Text(_formatDate(_endDate)),
                            onTap: () => _selectDate(isStart: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 420;

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickRangeButton(
                              compact: compact,
                              width: constraints.maxWidth,
                              onPressed: _setThisMonth,
                              icon: Icons.calendar_month,
                              label: 'Este mes',
                            ),
                            _QuickRangeButton(
                              compact: compact,
                              width: constraints.maxWidth,
                              onPressed: _setLastMonth,
                              icon: Icons.history,
                              label: 'Mes pasado',
                            ),
                            _QuickRangeButton(
                              compact: compact,
                              width: constraints.maxWidth,
                              onPressed: _setLast3Months,
                              icon: Icons.date_range,
                              label: '3 meses',
                            ),
                            _QuickRangeButton(
                              compact: compact,
                              width: constraints.maxWidth,
                              onPressed: _setThisYear,
                              icon: Icons.calendar_today,
                              label: 'Este año',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_exportResult != null) ...[
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Exportación exitosa!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      _exportResult!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isExporting ? null : _exportMovements,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        label: Text(
                            _isExporting ? 'Exportando...' : 'Exportar CSV'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month);
      _endDate = now;
    });
  }

  void _setLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    setState(() {
      _startDate = lastMonth;
      _endDate = lastMonthEnd;
    });
  }

  void _setLast3Months() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month - 3);
      _endDate = now;
    });
  }

  void _setThisYear() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year);
      _endDate = now;
    });
  }

  Future<void> _exportMovements() async {
    setState(() {
      _isExporting = true;
      _exportResult = null;
    });

    try {
      final movementRepo = context.read<MovementRepository>();

      // Get movements in date range
      final movements = await movementRepo.getMovementsByDateRange(
        _startDate,
        _endDate,
      );

      if (movements.isEmpty) {
        setState(() {
          _isExporting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay movimientos en el período seleccionado'),
            ),
          );
        }
        return;
      }

      // Export movements
      final path = await _exportService.exportAndShare(movements);

      setState(() {
        _isExporting = false;
        _exportResult = path.split('/').last;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportado: ${movements.length} movimientos'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

class _QuickRangeButton extends StatelessWidget {
  final bool compact;
  final double width;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _QuickRangeButton({
    required this.compact,
    required this.width,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? width : (width - 8) / 2,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
