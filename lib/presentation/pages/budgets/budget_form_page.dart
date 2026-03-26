// lib/presentation/pages/budgets/budget_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/currency_catalog.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_event.dart';

class BudgetFormPage extends StatefulWidget {
  final int? budgetId;

  const BudgetFormPage({super.key, this.budgetId});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  int? _selectedCategoryId;
  List<CategoryEntity> _categories = [];
  BudgetEntity? _existingBudget;
  bool _isLoading = true;
  bool _isSaving = false;
  String _currencyCode = 'ARS';

  int _periodMonth = DateTime.now().month;
  int _periodYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final categoryRepo = context.read<CategoryRepository>();
      final categories = await categoryRepo.getExpenseCategories();

      if (widget.budgetId != null) {
        final budgetRepo = context.read<BudgetRepository>();
        final budgets = await budgetRepo.getAllBudgets();
        _existingBudget =
            budgets.where((b) => b.id == widget.budgetId).firstOrNull;

        if (_existingBudget != null) {
          _limitController.text = _existingBudget!.limit.toString();
          _selectedCategoryId = _existingBudget!.categoryId;
          _periodMonth = _existingBudget!.periodMonth;
          _periodYear = _existingBudget!.periodYear;
        }
      }

      if (mounted) {
        setState(() {
          _categories = categories;
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _selectPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_periodYear, _periodMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      setState(() {
        _periodMonth = picked.month;
        _periodYear = picked.year;
      });
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final budget = BudgetEntity(
        id: _existingBudget?.id,
        categoryId: _selectedCategoryId!,
        limit:
            CurrencyFormatter.parseOrZero(_limitController.text, _currencyCode),
        periodMonth: _periodMonth,
        periodYear: _periodYear,
        createdAt: _existingBudget?.createdAt ?? DateTime.now(),
      );

      if (_existingBudget != null) {
        context.read<BudgetBloc>().add(UpdateBudget(budget: budget));
      } else {
        context.read<BudgetBloc>().add(CreateBudget(budget: budget));
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String get _periodLabel {
    const months = [
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
    return '${months[_periodMonth - 1]} $_periodYear';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budgetId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Presupuesto' : 'Nuevo Presupuesto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
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
                            validator: (value) => value == null
                                ? 'Selecciona una categoría'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _limitController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              CurrencyInputFormatter(
                                  currencyCode: _currencyCode),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Límite del presupuesto',
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
                                return 'El monto debe ser mayor a 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Período'),
                            subtitle: Text(_periodLabel),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _selectPeriod,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _isSaving ? null : _saveBudget,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(isEditing ? 'Actualizar' : 'Crear'),
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
    _limitController.dispose();
    super.dispose();
  }
}
