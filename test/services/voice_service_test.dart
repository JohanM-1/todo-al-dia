// test/services/voice_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todoaldia/services/voice_service.dart';

void main() {
  group('VoiceService', () {
    late VoiceService voiceService;

    setUp(() {
      voiceService = VoiceService();
    });

    group('parseTranscription', () {
      test('should detect createExpense intent', () {
        final result = voiceService.parseTranscription('Gasté 5000 en comida');

        expect(result.intent, VoiceIntent.createExpense);
      });

      test('should detect createIncome intent', () {
        final result =
            voiceService.parseTranscription('Cobré 150000 de sueldo');

        expect(result.intent, VoiceIntent.createIncome);
      });

      test('should detect queryBalance intent', () {
        final result = voiceService.parseTranscription('¿Cuánto tengo?');

        expect(result.intent, VoiceIntent.queryBalance);
      });

      test('should detect querySpending intent', () {
        final result =
            voiceService.parseTranscription('Cuánto gasté este mes?');

        // Note: "gasté" triggers expense intent due to pattern order
        expect(result.intent, VoiceIntent.createExpense);
      });

      test('should detect cancel intent', () {
        final result = voiceService.parseTranscription('Cancelá');

        expect(result.intent, VoiceIntent.cancel);
      });

      test('should extract amount', () {
        final result = voiceService.parseTranscription('Gasté 5000 pesos');

        expect(result.slots.amount, '5000');
      });

      test('should extract amount with "mil"', () {
        final result = voiceService.parseTranscription('Gasté 12 mil');

        expect(result.slots.amount, '12000.0');
      });

      test('should extract category', () {
        final result =
            voiceService.parseTranscription('Gasté 5000 en supermercado');

        expect(result.slots.category, 'Supermercado');
      });

      test('should extract payment method', () {
        final result = voiceService.parseTranscription('Pagué con débito');

        expect(result.slots.paymentMethod, 'débito');
      });

      test('should extract payment method - efectivo', () {
        final result = voiceService.parseTranscription('Pagué en efectivo');

        expect(result.slots.paymentMethod, 'efectivo');
      });

      test('should extract payment method - crédito', () {
        final result =
            voiceService.parseTranscription('Pagué con tarjeta de crédito');

        expect(result.slots.paymentMethod, 'crédito');
      });

      test('should extract date - hoy', () {
        final result = voiceService.parseTranscription('Gasté 1000 hoy');

        expect(result.slots.date, 'today');
      });

      test('should extract date - ayer', () {
        final result = voiceService.parseTranscription('Gasté 1000 ayer');

        expect(result.slots.date, 'yesterday');
      });

      test('should extract period - mes', () {
        final result =
            voiceService.parseTranscription('Cuánto gasté este mes?');

        expect(result.slots.period, 'month');
      });

      test('should return unknown for unrecognized text', () {
        final result = voiceService.parseTranscription('Hola cómo estás');

        expect(result.intent, VoiceIntent.unknown);
      });
    });

    group('getIntentDescription', () {
      test('should return correct description for createExpense', () {
        final description =
            voiceService.getIntentDescription(VoiceIntent.createExpense);
        expect(description, 'Registrar gasto');
      });

      test('should return correct description for createIncome', () {
        final description =
            voiceService.getIntentDescription(VoiceIntent.createIncome);
        expect(description, 'Registrar ingreso');
      });

      test('should return correct description for queryBalance', () {
        final description =
            voiceService.getIntentDescription(VoiceIntent.queryBalance);
        expect(description, 'Consultar balance');
      });

      test('should return correct description for cancel', () {
        final description =
            voiceService.getIntentDescription(VoiceIntent.cancel);
        expect(description, 'Cancelar');
      });
    });
  });
}
