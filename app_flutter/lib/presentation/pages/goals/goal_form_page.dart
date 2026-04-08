// lib/presentation/pages/goals/goal_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/currency_catalog.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../bloc/goal/goal_bloc.dart';
import '../../bloc/goal/goal_event.dart';

class GoalFormPage extends StatefulWidget {
  final int? goalId;

  const GoalFormPage({super.key, this.goalId});

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  GoalEntity? _existingGoal;
  GoalType _selectedGoalType = GoalType.savings;
  DateTime? _targetDate;
  bool _isLoading = true;
  bool _isSaving = false;
  int _selectedColorIndex = 0;
  String _currencyCode = 'ARS';

  static const _availableColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
  ];

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
      // Get existing goal from bloc state
      if (widget.goalId != null) {
        final blocState = context.read<GoalBloc>().state;
        _existingGoal =
            blocState.goals.where((g) => g.id == widget.goalId).firstOrNull;

        if (_existingGoal != null) {
          _nameController.text = _existingGoal!.name;
          _targetController.text = _existingGoal!.targetAmount.toString();
          _targetDate = _existingGoal!.targetDate;
          _selectedGoalType = _existingGoal!.goalType;
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
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

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12),
    );

    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final goal = GoalEntity(
        id: _existingGoal?.id,
        name: _nameController.text.trim(),
        goalType: _selectedGoalType,
        targetAmount: CurrencyFormatter.parseOrZero(
            _targetController.text, _currencyCode),
        currentAmount: _existingGoal?.currentAmount ?? 0.0,
        targetDate: _targetDate,
        isCompleted: _existingGoal?.isCompleted ?? false,
        isPaused: _existingGoal?.isPaused ?? false,
        createdAt: _existingGoal?.createdAt ?? DateTime.now(),
      );

      if (_existingGoal != null) {
        context.read<GoalBloc>().add(UpdateGoal(goal: goal));
      } else {
        context.read<GoalBloc>().add(CreateGoal(goal: goal));
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Meta' : 'Nueva Meta'),
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
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la meta',
                              hintText: 'Ej: Vacaciones de verano',
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa un nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _targetController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              CurrencyInputFormatter(
                                  currencyCode: _currencyCode),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Monto objetivo',
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
                          Text(
                            'Tipo de meta',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<GoalType>(
                            segments: const [
                              ButtonSegment(
                                value: GoalType.savings,
                                label: Text('Ahorro'),
                                icon: Icon(Icons.savings),
                              ),
                              ButtonSegment(
                                value: GoalType.expenseControl,
                                label: Text('Control'),
                                icon: Icon(Icons.control_camera),
                              ),
                              ButtonSegment(
                                value: GoalType.event,
                                label: Text('Evento'),
                                icon: Icon(Icons.event),
                              ),
                            ],
                            selected: {_selectedGoalType},
                            onSelectionChanged: (Set<GoalType> newSelection) {
                              setState(() {
                                _selectedGoalType = newSelection.first;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Fecha límite (opcional)'),
                            subtitle: Text(
                              _targetDate != null
                                  ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                                  : 'Sin fecha límite',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_targetDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        setState(() => _targetDate = null),
                                  ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                            onTap: _selectTargetDate,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Color',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              _availableColors.length,
                              (index) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedColorIndex = index),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _availableColors[index],
                                    shape: BoxShape.circle,
                                    border: _selectedColorIndex == index
                                        ? Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                  child: _selectedColorIndex == index
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 20)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _isSaving ? null : _saveGoal,
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
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}
