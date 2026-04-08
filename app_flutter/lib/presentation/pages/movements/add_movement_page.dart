// lib/presentation/pages/movements/add_movement_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/currency_catalog.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../../services/voice_service.dart';

class AddMovementPage extends StatefulWidget {
  const AddMovementPage({super.key});

  @override
  State<AddMovementPage> createState() => _AddMovementPageState();
}

class _AddMovementPageState extends State<AddMovementPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _merchantController = TextEditingController();

  MovementType _type = MovementType.expense;
  int? _selectedCategoryId;
  String? _paymentMethod;
  DateTime _date = DateTime.now();
  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  bool _isCategoriesLoading = true;
  int? _defaultAccountId;
  String _currencyCode = 'COP';

  // Voice - lazy initialization
  VoiceService? _voiceService;
  bool _isListening = false;
  bool _isTestingMicrophone = false;
  String _transcription = '';
  bool _isVoiceAvailable = false;
  double _soundLevel = 0;
  double _maxSoundLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadDefaultAccount();
    _loadCurrency();
    _initializeVoice();
  }

  Future<void> _loadCurrency() async {
    final currency = await AppDatabase.instance.getSetting('currency');
    if (mounted && currency != null) {
      setState(() {
        _currencyCode = currency;
      });
    }
  }

  VoiceService get voiceService {
    _voiceService ??= VoiceService();
    return _voiceService!;
  }

  Future<void> _loadDefaultAccount() async {
    try {
      final accounts = await context.read<AccountRepository>().getAllAccounts();

      if (!mounted) return;

      setState(() {
        _defaultAccountId = accounts.isNotEmpty ? accounts.first.id : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _defaultAccountId = null;
      });
    }
  }

  Future<void> _initializeVoice() async {
    final available = await voiceService.initialize();
    if (!mounted) return;

    setState(() {
      _isVoiceAvailable = available;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final repo = context.read<CategoryRepository>();
      final categories = _type == MovementType.expense
          ? await repo.getExpenseCategories()
          : await repo.getIncomeCategories();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isCategoriesLoading = false;
          if (categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCategoriesLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cargando categorías: $e')),
          );
        }
      }
    }
  }

  void _onTypeChanged(MovementType? type) {
    if (type != null) {
      setState(() {
        _type = type;
        _selectedCategoryId = null;
        _categories = [];
        _isCategoriesLoading = true;
      });
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

  Future<void> _startVoiceListening({bool validationOnly = false}) async {
    if (!_isVoiceAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('La función de voz no está disponible. Usá el teclado.'),
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _isTestingMicrophone = validationOnly;
      _transcription = '';
      _soundLevel = 0;
      _maxSoundLevel = 0;
    });

    await voiceService.startListening(
      onResult: (text) {
        if (!mounted) return;
        setState(() => _transcription = text);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _isListening = false);
        if (_isTestingMicrophone) {
          _finishMicrophoneValidation();
          return;
        }
        _processVoiceResult();
      },
      onError: () {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _isTestingMicrophone = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No se pudo usar el micrófono. Probá con el teclado.'),
          ),
        );
      },
      onSoundLevelChange: (level) {
        if (!mounted) return;
        final safeLevel =
            level.isFinite ? level.clamp(0.0, 500.0).toDouble() : 0.0;
        setState(() {
          _soundLevel = safeLevel;
          if (safeLevel > _maxSoundLevel) {
            _maxSoundLevel = safeLevel;
          }
        });
      },
      listenFor: validationOnly
          ? const Duration(seconds: 8)
          : const Duration(seconds: 30),
      pauseFor: validationOnly
          ? const Duration(seconds: 2)
          : const Duration(seconds: 3),
    );
  }

  Future<void> _stopVoiceListening() async {
    await voiceService.stopListening();
    if (!mounted) return;
    setState(() => _isListening = false);
    if (_isTestingMicrophone) {
      _finishMicrophoneValidation();
      return;
    }
    _processVoiceResult();
  }

  void _finishMicrophoneValidation() {
    final detectedInput =
        _maxSoundLevel > 8 || _transcription.trim().isNotEmpty;

    setState(() {
      _isTestingMicrophone = false;
      _soundLevel = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          detectedInput
              ? 'Micrófono detectado correctamente. La app usa el micrófono predeterminado del sistema.'
              : 'No detecté entrada del micrófono. Revisá permisos y el micrófono predeterminado del sistema.',
        ),
        backgroundColor: detectedInput ? Colors.green : Colors.orange,
      ),
    );
  }

  void _processVoiceResult() {
    if (_transcription.isEmpty || _voiceService == null) return;

    final result = voiceService.parseTranscription(_transcription);

    // Update form based on parsed slots
    if (result.slots.amount != null) {
      _amountController.text = result.slots.amount!;
    }
    if (result.slots.merchant != null) {
      _merchantController.text = result.slots.merchant!;
    }
    if (result.slots.note != null) {
      _noteController.text = result.slots.note!;
    }

    // Show parsed intent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Entendido: ${voiceService.getIntentDescription(result.intent)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
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

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final movement = MovementEntity(
        uuid: const Uuid().v4(),
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
        context.pop(true);
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
              child: _isCategoriesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Type selector
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

                          // Voice button
                          Card(
                            color: _isListening ? Colors.red.shade100 : null,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    _isListening
                                        ? 'Escuchando...'
                                        : _transcription.isNotEmpty
                                            ? _transcription
                                            : 'Toca para hablar',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    key: const ValueKey('add_voice_button'),
                                    onPressed: _isListening
                                        ? _stopVoiceListening
                                        : (_isVoiceAvailable
                                            ? () => _startVoiceListening()
                                            : null),
                                    icon: Icon(
                                        _isListening ? Icons.stop : Icons.mic),
                                    label: Text(_isListening
                                        ? 'Detener'
                                        : _isVoiceAvailable
                                            ? 'Hablar'
                                            : 'No disponible'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _isListening ? Colors.red : null,
                                      foregroundColor:
                                          _isListening ? Colors.white : null,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed:
                                        _isListening || !_isVoiceAvailable
                                            ? null
                                            : () => _startVoiceListening(
                                                  validationOnly: true,
                                                ),
                                    icon: const Icon(
                                        Icons.mic_external_on_outlined),
                                    label: const Text('Probar micrófono'),
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: _isListening
                                        ? (_soundLevel / 500).clamp(0.0, 1.0)
                                        : 0,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isTestingMicrophone
                                        ? 'Hablá unos segundos para validar el micrófono.'
                                        : 'La app usa el micrófono predeterminado del sistema.',
                                    textAlign: TextAlign.center,
                                  ),
                                  if (!_isVoiceAvailable) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tu dispositivo o navegador no soporta voz en esta pantalla. Podés seguir con el teclado.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Amount
                          TextFormField(
                            controller: _amountController,
                            autofocus: true,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              CurrencyInputFormatter(
                                  currencyCode: _currencyCode),
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

                          // Category
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
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona una categoría';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Merchant
                          TextFormField(
                            controller: _merchantController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Comercio (opcional)',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Payment method
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

                          // Date
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

                          // Note
                          TextFormField(
                            controller: _noteController,
                            textInputAction: TextInputAction.done,
                            maxLines: 3,
                            onFieldSubmitted: (_) => _saveMovement(),
                            decoration: const InputDecoration(
                              labelText: 'Nota (opcional)',
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Save button
                          FilledButton(
                            key: const ValueKey('add_save_button'),
                            onPressed: _isLoading ? null : _saveMovement,
                            child: _isLoading
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Guardando...'),
                                    ],
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
    _voiceService?.stopListening();
    _amountController.dispose();
    _noteController.dispose();
    _merchantController.dispose();
    super.dispose();
  }
}
