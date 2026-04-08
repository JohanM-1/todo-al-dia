// lib/presentation/pages/voice/voice_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../services/voice_service.dart';
import '../../bloc/movement/movement_bloc.dart';
import '../../bloc/movement/movement_event.dart' as events;
import '../../widgets/currency_text_field.dart';

class VoiceConfirmationScreen extends StatefulWidget {
  final VoiceResult voiceResult;
  final int? accountId;

  const VoiceConfirmationScreen({
    super.key,
    required this.voiceResult,
    this.accountId,
  });

  @override
  State<VoiceConfirmationScreen> createState() =>
      _VoiceConfirmationScreenState();
}

class _VoiceConfirmationScreenState extends State<VoiceConfirmationScreen> {
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _amountController = TextEditingController();
  int? _selectedAccountId;
  int? _selectedCategoryId;
  late MovementType _movementType;
  late double _amount;
  late DateTime _date;
  late String? _merchant;
  late String? _paymentMethod;
  late String? _note;
  bool _isLoading = false;
  List<CategoryEntity> _categories = [];
  List<AccountEntity> _accounts = [];

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.accountId;
    _movementType = widget.voiceResult.intent == VoiceIntent.createIncome
        ? MovementType.income
        : MovementType.expense;
    _amount = CurrencyFormatter.parseOrZero(
      widget.voiceResult.slots.amount ?? '0',
      AppDatabase.currentCurrency,
    );
    _amountController.text = _amount > 0
        ? CurrencyFormatter.formatNumber(_amount, AppDatabase.currentCurrency)
        : '';
    _merchant = widget.voiceResult.slots.merchant;
    _paymentMethod = widget.voiceResult.slots.paymentMethod;
    _note = widget.voiceResult.slots.note;
    _date = _parseDate(widget.voiceResult.slots.date);
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    switch (dateStr) {
      case 'today':
        return DateTime.now();
      case 'yesterday':
        return DateTime.now().subtract(const Duration(days: 1));
      case 'dayBeforeYesterday':
        return DateTime.now().subtract(const Duration(days: 2));
      default:
        return DateTime.now();
    }
  }

  Future<void> _loadData() async {
    final categoryRepo = context.read<CategoryRepository>();
    final accountRepo = context.read<AccountRepository>();

    final categories = _movementType == MovementType.expense
        ? await categoryRepo.getExpenseCategories()
        : await categoryRepo.getIncomeCategories();
    final accounts = await accountRepo.getAllAccounts();

    if (mounted) {
      setState(() {
        _categories = categories;
        _accounts = accounts;

        if (_selectedAccountId == null && accounts.isNotEmpty) {
          _selectedAccountId = accounts.first.id;
        }

        final categoryName = widget.voiceResult.slots.category;
        if (categoryName != null) {
          final matched = categories.where(
            (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
          );
          if (matched.isNotEmpty) {
            _selectedCategoryId = matched.first.id;
          }
        }
        if (_selectedCategoryId == null && categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
      });
    }
  }

  Future<void> _saveMovement() async {
    if (_selectedAccountId == null ||
        _selectedCategoryId == null ||
        _amount <= 0) {
      return;
    }

    setState(() => _isLoading = true);

    final movement = MovementEntity(
      uuid: DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      type: _movementType,
      amount: _amount,
      merchant: _merchant,
      paymentMethod: _paymentMethod,
      note: _note,
      date: _date,
      createdAt: DateTime.now(),
    );

    context.read<MovementBloc>().add(events.CreateMovement(movement: movement));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(theme),
                          const SizedBox(height: 24),
                          _buildAmountField(theme),
                          const SizedBox(height: 16),
                          _buildAccountDropdown(theme),
                          const SizedBox(height: 16),
                          _buildCategoryDropdown(theme),
                          const SizedBox(height: 16),
                          _buildDatePicker(theme),
                          if (_paymentMethod != null) ...[
                            const SizedBox(height: 16),
                            _buildPaymentMethodField(theme),
                          ],
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              key: const ValueKey('voice_confirm_save'),
                              onPressed: _amount > 0 ? _saveMovement : null,
                              icon: const Icon(Icons.check),
                              label: const Text('Confirmar'),
                            ),
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

  Widget _buildSummaryCard(ThemeData theme) {
    final intentLabel = _voiceService.getIntentDescription(
      widget.voiceResult.intent,
    );

    return Card(
      color: _movementType == MovementType.expense
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _movementType == MovementType.expense
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: _movementType == MovementType.expense
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  intentLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _movementType == MovementType.expense
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"${widget.voiceResult.transcription}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _movementType == MovementType.expense
                    ? theme.colorScheme.onErrorContainer.withValues(alpha: 0.8)
                    : theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    return CurrencyTextField(
      controller: _amountController,
      currencyCode: AppDatabase.currentCurrency,
      labelText: 'Monto',
      onChanged: (value) {
        setState(() {
          _amount = CurrencyFormatter.parseOrZero(
            value,
            AppDatabase.currentCurrency,
          );
        });
      },
    );
  }

  Widget _buildAccountDropdown(ThemeData theme) {
    return DropdownButtonFormField<int>(
      value: _selectedAccountId,
      decoration: const InputDecoration(
        labelText: 'Cuenta',
        border: OutlineInputBorder(),
      ),
      items: _accounts.map((account) {
        return DropdownMenuItem(
          value: account.id,
          child: Text(account.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedAccountId = value;
        });
      },
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text('${category.icon} ${category.name}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _date = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_date.day}/${_date.month}/${_date.year}',
              style: theme.textTheme.bodyLarge,
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField(ThemeData theme) {
    return TextFormField(
      initialValue: _paymentMethod,
      decoration: const InputDecoration(
        labelText: 'Método de pago',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _paymentMethod = value.isEmpty ? null : value;
        });
      },
    );
  }
}
