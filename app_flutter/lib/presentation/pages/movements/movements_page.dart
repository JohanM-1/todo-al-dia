// lib/presentation/pages/movements/movements_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/page_hero_card.dart';
import '../../widgets/quick_add_floating_button.dart';

class MovementsPage extends StatefulWidget {
  const MovementsPage({super.key});

  @override
  State<MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends State<MovementsPage> {
  List<MovementEntity> _movements = [];
  List<CategoryEntity> _categories = [];
  bool _isLoading = true;
  String? _error;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  int? _filterCategoryId;
  MovementType? _filterType;

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movementRepo = context.read<MovementRepository>();
      final categoryRepo = context.read<CategoryRepository>();

      List<MovementEntity> movements;
      if (_filterStartDate != null && _filterEndDate != null) {
        movements = await movementRepo.getMovementsByDateRange(
          _filterStartDate!,
          _filterEndDate!,
        );
      } else if (_filterCategoryId != null) {
        movements =
            await movementRepo.getMovementsByCategory(_filterCategoryId!);
      } else {
        movements = await movementRepo.getAllMovements();
      }

      if (_filterType != null) {
        movements = movements.where((m) => m.type == _filterType).toList();
      }

      movements.sort((a, b) => b.date.compareTo(a.date));

      final categories = await categoryRepo.getAllCategories();

      if (mounted) {
        setState(() {
          _movements = movements;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showFilterDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        initialStartDate: _filterStartDate,
        initialEndDate: _filterEndDate,
        initialCategoryId: _filterCategoryId,
        initialType: _filterType,
        categories: _categories,
        onApply: (startDate, endDate, categoryId, type) {
          setState(() {
            _filterStartDate = startDate;
            _filterEndDate = endDate;
            _filterCategoryId = categoryId;
            _filterType = type;
          });
          unawaited(_loadData());
        },
        onClear: () {
          setState(() {
            _filterStartDate = null;
            _filterEndDate = null;
            _filterCategoryId = null;
            _filterType = null;
          });
          unawaited(_loadData());
        },
      ),
    );
  }

  Future<void> _deleteMovement(MovementEntity movement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Movimiento'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este movimiento?'),
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

    if (!mounted) {
      return;
    }

    if (confirmed == true && movement.id != null) {
      try {
        final movementRepository = context.read<MovementRepository>();
        await movementRepository.deleteMovement(movement.id!);
        if (!mounted) {
          return;
        }

        context.read<DashboardBloc>().add(LoadDashboard());
        unawaited(_loadData());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento eliminado')),
        );
      } catch (e) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final isDesktop = constraints.maxWidth >= 900;
        final horizontalPadding = isDesktop ? 24.0 : 16.0;
        final maxContentWidth =
            isDesktop ? 1000.0 : (isWide ? 800.0 : double.infinity);
        final hasFilters = _filterStartDate != null ||
            _filterEndDate != null ||
            _filterCategoryId != null ||
            _filterType != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Movimientos'),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: _filterStartDate != null ||
                      _filterEndDate != null ||
                      _filterCategoryId != null ||
                      _filterType != null,
                  child: const Icon(Icons.filter_list),
                ),
                onPressed: _showFilterDialog,
                tooltip: 'Filtrar movimientos',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                112,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageHeroCard(
                        eyebrow: 'Historial diario',
                        title: 'Tus movimientos en un solo lugar.',
                        subtitle:
                            'Filtrá rápido, encontrá patrones y corregí registros sin perder contexto visual.',
                        icon: Icons.receipt_long_rounded,
                        actions: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await context.push('/add');
                              if (!mounted) {
                                return;
                              }
                              unawaited(_loadData());
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Agregar movimiento'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _showFilterDialog,
                            icon: const Icon(Icons.tune_rounded),
                            label: Text(
                              hasFilters ? 'Editar filtros' : 'Filtrar lista',
                            ),
                          ),
                        ],
                        footer: [
                          HeroBadge(
                            label: '${_movements.length} registros',
                            color: Theme.of(context).colorScheme.primary,
                            icon: Icons.dataset_outlined,
                          ),
                          HeroBadge(
                            label: hasFilters
                                ? 'Filtros activos'
                                : 'Vista completa',
                            color: hasFilters
                                ? AppTheme.warningColor
                                : Theme.of(context).colorScheme.onSurface,
                            icon: hasFilters
                                ? Icons.filter_alt_rounded
                                : Icons.check_circle_outline_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildBody(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: QuickAddFloatingButton(
            isExtended: isWide,
            onPressed: () async {
              await context.push('/add');
              if (!mounted) {
                return;
              }
              unawaited(_loadData());
            },
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyStateCard(
        icon: Icons.error_outline_rounded,
        title: 'No pudimos cargar los movimientos',
        subtitle: '$_error',
        action: ElevatedButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      );
    }

    if (_movements.isEmpty) {
      return EmptyStateCard(
        icon: Icons.receipt_long_rounded,
        title: 'Todavía no hay movimientos',
        subtitle:
            'Registrá ingresos o gastos para empezar a leer tu historia financiera con contexto real.',
        action: ElevatedButton.icon(
          onPressed: () => context.push('/add'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Agregar primer movimiento'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _movements.length,
      itemBuilder: (context, index) {
        final movement = _movements[index];
        final category = _categories.firstWhere(
          (c) => c.id == movement.categoryId,
          orElse: () => const CategoryEntity(
            name: 'Sin categoría',
          ),
        );

        return Dismissible(
          key: Key(movement.uuid),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child:
                const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar'),
                content: const Text('¿Eliminar este movimiento?'),
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
          },
          onDismissed: (_) => _deleteMovement(movement),
          child: GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(category.icon),
              ),
              title: Text(category.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (movement.merchant != null &&
                      movement.merchant!.isNotEmpty)
                    Text(movement.merchant!),
                  Text(
                    '${movement.date.day}/${movement.date.month}/${movement.date.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: Text(
                '${movement.type == MovementType.expense ? '-' : ''}${CurrencyFormatter.formatWithSymbol(movement.amount, AppDatabase.currentCurrency)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: movement.type == MovementType.expense
                          ? AppTheme.expenseColor
                          : AppTheme.incomeColor,
                    ),
              ),
              onTap: () async {
                await context.push('/movement/edit/${movement.id}');
                if (!mounted) {
                  return;
                }
                unawaited(_loadData());
              },
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final int? initialCategoryId;
  final MovementType? initialType;
  final List<CategoryEntity> categories;
  final void Function(DateTime?, DateTime?, int?, MovementType?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    this.initialStartDate,
    this.initialEndDate,
    this.initialCategoryId,
    this.initialType,
    required this.categories,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late int? _categoryId;
  late MovementType? _type;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _categoryId = widget.initialCategoryId;
    _type = widget.initialType;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: GlassCard(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrar movimientos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Tipo', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _type == null,
                    onSelected: (_) => setState(() => _type = null),
                  ),
                  FilterChip(
                    label: const Text('Gastos'),
                    selected: _type == MovementType.expense,
                    onSelected: (_) =>
                        setState(() => _type = MovementType.expense),
                  ),
                  FilterChip(
                    label: const Text('Ingresos'),
                    selected: _type == MovementType.income,
                    onSelected: (_) =>
                        setState(() => _type = MovementType.income),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Fecha', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectStartDate,
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Desde',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectEndDate,
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Hasta',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Categoría', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(child: Text('Todas')),
                  ...widget.categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.icon} ${c.name}'),
                      )),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_startDate, _endDate, _categoryId, _type);
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
