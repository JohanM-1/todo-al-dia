// lib/presentation/pages/movements/movement_form_page.dart
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

class MovementFormPage extends StatefulWidget {
  const MovementFormPage({super.key});

  @override
  State<MovementFormPage> createState() => _MovementFormPageState();
}

class _MovementFormPageState extends State<MovementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _merchantController = TextEditingController();

  MovementType _type = MovementType.expense;
  int? _selectedCategoryId;
  String? _paymentMethod;
  DateTime _date = DateTime.now();
  List<CategoryEntity> _categories = [];
  int? _defaultAccountId;
  bool _isLoading = false;
  String _currencyCode = 'COP';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadDefaultAccount();
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

  Future<void> _loadDefaultAccount() async {
    final accounts = await context.read<AccountRepository>().getAllAccounts();

    if (mounted) {
      setState(() {
        _defaultAccountId = accounts.isNotEmpty ? accounts.first.id : null;
      });
    }
  }

  Future<void> _loadCategories() async {
    final repo = context.read<CategoryRepository>();
    final categories = _type == MovementType.expense
        ? await repo.getExpenseCategories()
        : await repo.getIncomeCategories();

    if (mounted) {
      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
      });
    }
  }

  void _onTypeChanged(MovementType? type) {
    if (type != null) {
      setState(() => _type = type);
      _loadCategories();
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

  Future<void> _saveMovement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_defaultAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay una cuenta disponible para guardar')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final movement = MovementEntity(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: _defaultAccountId!,
        categoryId: _selectedCategoryId!,
        type: _type,
        amount: CurrencyFormatter.parseOrZero(
            _amountController.text, _currencyCode),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        merchant:
            _merchantController.text.isEmpty ? null : _merchantController.text,
        paymentMethod: _paymentMethod,
        date: _date,
        createdAt: DateTime.now(),
      );

      await context.read<MovementRepository>().createMovement(movement);

      if (mounted) {
        context.read<DashboardBloc>().add(LoadDashboard());
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Movimiento'),
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
                      onPressed: _isLoading ? null : _saveMovement,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
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
