// integration_test/pages/add_movement_page.dart
//
// Page Object for the Add Movement form.
// Used in E2E tests to add gastos and ingresos via form input
// (simulating voice-parsed results in CI environments without microphone).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show find, Finder;
import 'package:patrol/patrol.dart';

Finder valueKey(String key) => find.byKey(ValueKey(key));

class AddMovementPage {
  AddMovementPage(this.$);

  final PatrolIntegrationTester $;

  String get voiceButtonKey => 'add_voice_button';
  String get saveButtonKey => 'add_save_button';
  String get expenseSegmentLabel => 'Gasto';
  String get incomeSegmentLabel => 'Ingreso';

  /// Fills the amount field (first TextFormField), optional fields, and saves.
  /// By default creates an expense (Gasto).
  Future<void> fillAndSaveGasto({
    required double amount,
    String? note,
    String? merchant,
  }) async {
    final amountField = find.byType(TextFormField).first;
    await $.enterText(amountField, amount.toStringAsFixed(2));
    await $.pumpAndSettle();

    if (merchant != null) {
      final merchantField = find.byType(TextFormField).at(1);
      await $.enterText(merchantField, merchant);
      await $.pumpAndSettle();
    }

    if (note != null) {
      final noteField = find.byType(TextFormField).last;
      await $.enterText(noteField, note);
      await $.pumpAndSettle();
    }

    await $.tap(valueKey(saveButtonKey));
    await $.pumpAndSettle();
  }

  /// Selects "Ingreso" type and saves the given amount.
  Future<void> fillAndSaveIngreso({
    required double amount,
    String? note,
  }) async {
    await $.tap(find.text(incomeSegmentLabel));
    await $.pumpAndSettle();
    await fillAndSaveGasto(amount: amount, note: note);
  }

  /// Returns true if the save button is visible.
  Future<bool> get isSaveVisible async {
    try {
      await $(valueKey(saveButtonKey)).waitUntilVisible();
      return true;
    } catch (_) {
      return false;
    }
  }
}
