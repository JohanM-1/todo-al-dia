// lib/services/voice_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Intent detected from voice transcription.
enum VoiceIntent {
  createExpense,
  createIncome,
  queryBalance,
  querySpending,
  showDetails,
  editLastTransaction,
  cancel,
  unknown,
}

/// Extracted parameters from voice transcription.
class VoiceSlot {
  final String? amount;
  final String? currency;
  final String? category;
  final String? merchant;
  final String? paymentMethod;
  final String? date;
  final String? note;
  final String? period;
  final String? field;
  final String? value;

  const VoiceSlot({
    this.amount,
    this.currency,
    this.category,
    this.merchant,
    this.paymentMethod,
    this.date,
    this.note,
    this.period,
    this.field,
    this.value,
  });
}

/// Result of voice transcription with parsed intent and slots.
class VoiceResult {
  final String transcription;
  final VoiceIntent intent;
  final VoiceSlot slots;
  final double confidence;

  const VoiceResult({
    required this.transcription,
    required this.intent,
    required this.slots,
    required this.confidence,
  });
}

/// Service for voice recognition and intent parsing.
/// Wraps speech_to_text and provides Spanish financial voice commands.
class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
    } catch (error) {
      debugPrint('Speech initialization failed: $error');
      _isInitialized = false;
    }

    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    void Function()? onDone,
    void Function()? onError,
    void Function(double level)? onSoundLevelChange,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call();
        return;
      }
    }

    if (_isListening) {
      await stopListening();
    }

    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          _isListening = false;
          onDone?.call();
        }
      },
      listenFor: listenFor,
      pauseFor: pauseFor,
      localeId: localeId,
      onSoundLevelChange: onSoundLevelChange,
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  VoiceResult parseTranscription(String text) {
    final lowerText = text.toLowerCase();

    // Detect intent
    final intent = _detectIntent(lowerText);

    // Extract slots
    final slots = _extractSlots(lowerText, intent);

    return VoiceResult(
      transcription: text,
      intent: intent,
      slots: slots,
      confidence: 0.8, // Simplified confidence
    );
  }

  VoiceIntent _detectIntent(String text) {
    // Create expense patterns
    final expensePatterns = [
      'gasté',
      'gaste',
      'pagué',
      'pague',
      'compré',
      'compre',
      'pagué',
      'débito',
      'crédito',
      'efectivo',
      'tarjeta',
    ];

    // Create income patterns
    final incomePatterns = [
      'cobré',
      'cobre',
      'recibí',
      'recibí',
      'me pagaron',
      'ingresé',
      'transferencia',
      'depósito',
      'depósito',
    ];

    // Query patterns
    final balancePatterns = [
      'cuánto tengo',
      'cuanto tengo',
      'balance',
      'cuánto me queda',
      'cuanto me queda',
      'cómo voy',
      'como voy',
    ];

    final spendingPatterns = [
      'cuánto gasté',
      'cuanto gasté',
      'en qué gasté',
      'en que gasté',
      'gastos de',
      'gastado en',
    ];

    final detailPatterns = [
      'mostrame',
      'mostrá',
      'detalle',
      'lista',
      'abrí',
      'ver más',
    ];

    final editPatterns = [
      'editá',
      'edita',
      'cambiá',
      'cambia',
      'modificá',
      'modifica',
      'era',
      'fue',
    ];

    final cancelPatterns = [
      'cancelá',
      'cancela',
      'no guardes',
      'olvidalo',
      'olvídalo',
    ];

    // Check for cancel first
    for (final pattern in cancelPatterns) {
      if (text.contains(pattern)) return VoiceIntent.cancel;
    }

    // Check for expense
    for (final pattern in expensePatterns) {
      if (text.contains(pattern)) return VoiceIntent.createExpense;
    }

    // Check for income
    for (final pattern in incomePatterns) {
      if (text.contains(pattern)) return VoiceIntent.createIncome;
    }

    // Check for balance query
    for (final pattern in balancePatterns) {
      if (text.contains(pattern)) return VoiceIntent.queryBalance;
    }

    // Check for spending query
    for (final pattern in spendingPatterns) {
      if (text.contains(pattern)) return VoiceIntent.querySpending;
    }

    // Check for details
    for (final pattern in detailPatterns) {
      if (text.contains(pattern)) return VoiceIntent.showDetails;
    }

    // Check for edit
    for (final pattern in editPatterns) {
      if (text.contains(pattern)) return VoiceIntent.editLastTransaction;
    }

    return VoiceIntent.unknown;
  }

  VoiceSlot _extractSlots(String text, VoiceIntent intent) {
    // Extract amount
    String? amount;
    final amountPatterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*(?:mil|k|pesos?|ars|\$)',
          caseSensitive: false),
      RegExp(r'\$(\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?)\s*(?:pesos?|ars)', caseSensitive: false),
    ];

    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        amount = match.group(1)?.replaceAll(',', '.') ?? match.group(2);
        if (amount != null && (text.contains('mil') || text.contains('k'))) {
          final numAmount = double.tryParse(amount);
          if (numAmount != null) {
            amount = (numAmount * 1000).toString();
          }
        }
        break;
      }
    }

    // Extract category
    String? category;
    final categories = {
      'comida': 'Comida',
      'restaurante': 'Comida',
      'supermercado': 'Supermercado',
      'transporte': 'Transporte',
      'uber': 'Transporte',
      'taxi': 'Transporte',
      'nafta': 'Transporte',
      'casa': 'Casa',
      'alquiler': 'Casa',
      'entretenimiento': 'Entretenimiento',
      'cine': 'Entretenimiento',
      'netflix': 'Entretenimiento',
      'salud': 'Salud',
      'farmacia': 'Salud',
      'doctor': 'Salud',
      'ropa': 'Ropa',
      'servicios': 'Servicios',
      'luz': 'Servicios',
      'agua': 'Servicios',
      'internet': 'Servicios',
      'celular': 'Servicios',
      'regalos': 'Regalos',
      'sueldo': 'Salario',
      'freelance': 'Freelance',
    };

    for (final entry in categories.entries) {
      if (text.contains(entry.key)) {
        category = entry.value;
        break;
      }
    }

    // Extract payment method
    String? paymentMethod;
    if (text.contains('efectivo') || text.contains('cash')) {
      paymentMethod = 'efectivo';
    } else if (text.contains('débito') || text.contains('debito')) {
      paymentMethod = 'débito';
    } else if (text.contains('crédito') || text.contains('credito')) {
      paymentMethod = 'crédito';
    } else if (text.contains('transferencia')) {
      paymentMethod = 'transferencia';
    }

    // Extract date
    String? date;
    if (text.contains('hoy')) {
      date = 'today';
    } else if (text.contains('ayer')) {
      date = 'yesterday';
    } else if (text.contains('anteayer') || text.contains('antes de ayer')) {
      date = 'dayBeforeYesterday';
    }

    // Extract period
    String? period;
    if (text.contains('este mes') || text.contains('del mes')) {
      period = 'month';
    } else if (text.contains('esta semana') || text.contains('de la semana')) {
      period = 'week';
    } else if (text.contains('este año') || text.contains('del año')) {
      period = 'year';
    }

    // Extract merchant
    String? merchant;
    // Simple merchant extraction - could be enhanced
    final merchantPatterns = [
      RegExp(r'en\s+([a-zA-Z]+)', caseSensitive: false),
    ];

    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && category == null) {
        merchant = match.group(1);
        break;
      }
    }

    return VoiceSlot(
      amount: amount,
      category: category,
      merchant: merchant,
      paymentMethod: paymentMethod,
      date: date,
      period: period,
    );
  }

  String getIntentDescription(VoiceIntent intent) {
    switch (intent) {
      case VoiceIntent.createExpense:
        return 'Registrar gasto';
      case VoiceIntent.createIncome:
        return 'Registrar ingreso';
      case VoiceIntent.queryBalance:
        return 'Consultar balance';
      case VoiceIntent.querySpending:
        return 'Consultar gastos';
      case VoiceIntent.showDetails:
        return 'Mostrar detalle';
      case VoiceIntent.editLastTransaction:
        return 'Editar último movimiento';
      case VoiceIntent.cancel:
        return 'Cancelar';
      case VoiceIntent.unknown:
        return 'No entendido';
    }
  }
}
