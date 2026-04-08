// lib/presentation/pages/movements/movement_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/currency_catalog.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';

class MovementEditPage extends StatefulWidget {
  final int movementId;

  const MovementEditPage({super.key, required this.movementId});

  @override
  State<MovementEditPage> createState() => _MovementEditPageState();
}

class _MovementEditPageState extends State<MovementEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _merchantController = TextEditingController();

  MovementEntity? _movement;
  MovementType _type = MovementType.expense;
  int? _selectedCategoryId;
  String? _paymentMethod;
  DateTime _date = DateTime.now();
  List<CategoryEntity> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _currencyCode = 'COP';

  @override
  void initState() {
    super.initState();
    _loadMovement();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currency = await AppDatabase.instance.getSetting('currency');
    if (mounted && currency != null) {
      setState(() {
        _currencyCode = currency;
      });
    }
  }

  Future<void> _loadMovement() async {
    try {
      final repo = context.read<MovementRepository>();
      final movements = await repo.getAllMovements();
      final movement = movements.firstWhere(
        (m) => m.id == widget.movementId,
        orElse: () => throw Exception('Movimiento no encontrado'),
      );

      final categoryRepo = context.read<CategoryRepository>();
      final categories = await categoryRepo.getAllCategories();

      if (mounted) {
        setState(() {
          _movement = movement;
          _type = movement.type;
          _selectedCategoryId = movement.categoryId;
          _amountController.text = movement.amount.toString();
          _noteController.text = movement.note ?? '';
          _merchantController.text = movement.merchant ?? '';
          _paymentMethod = movement.paymentMethod;
          _date = movement.date;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        context.pop();
      }
    }
  }

  void _onTypeChanged(MovementType? type) {
    if (type != null) {
      setState(() => _type = type);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _updateMovement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _movement == null) return;

    setState(() => _isSaving = true);

    try {
      final updated = _movement!.copyWith(
        type: _type,
        categoryId: _selectedCategoryId,
        amount: CurrencyFormatter.parseOrZero(
            _amountController.text, _currencyCode),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        merchant:
            _merchantController.text.isEmpty ? null : _merchantController.text,
        paymentMethod: _paymentMethod,
        date: _date,
        updatedAt: DateTime.now(),
      );

      await context.read<MovementRepository>().updateMovement(updated);

      if (mounted) {
        context.read<DashboardBloc>().add(LoadDashboard());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento actualizado')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteMovement() async {
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

    if (confirmed == true) {
      try {
        await context
            .read<MovementRepository>()
            .deleteMovement(widget.movementId);
        if (mounted) {
          context.read<DashboardBloc>().add(LoadDashboard());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Movimiento eliminado')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Movimiento')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Movimiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteMovement,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isTablet = constraints.maxWidth >= 600;
          final maxWidth =
              isWide ? 600.0 : (isTablet ? 500.0 : double.infinity);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SegmentedButton<MovementType>(
                      segments: const [
                        ButtonSegment(
                          value: MovementType.expense,
                          label: Text('Gasto'),
                          icon: Icon(Icons.remove_circle_outline),
                        ),
                        ButtonSegment(
                          value: MovementType.income,
                          label: Text('Ingreso'),
                          icon: Icon(Icons.add_circle_outline),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (selection) =>
                          _onTypeChanged(selection.first),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        CurrencyInputFormatter(currencyCode: _currencyCode),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        prefixText:
                            '${CurrencyCatalog.getSymbol(_currencyCode)} ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa un monto';
                        }
                        final parsed =
                            CurrencyFormatter.parse(value, _currencyCode);
                        if (parsed == null || parsed <= 0) {
                          return 'Monto inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Text('${cat.icon} ${cat.name}'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategoryId = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _merchantController,
                      decoration: const InputDecoration(
                        labelText: 'Comercio (opcional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Método de pago (opcional)',
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(
                            value: 'débito', child: Text('Débito')),
                        DropdownMenuItem(
                            value: 'crédito', child: Text('Crédito')),
                        DropdownMenuItem(
                            value: 'transferencia',
                            child: Text('Transferencia')),
                      ],
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fecha'),
                      subtitle: Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Nota (opcional)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSaving ? null : _updateMovement,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar cambios'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _merchantController.dispose();
    super.dispose();
  }
}
