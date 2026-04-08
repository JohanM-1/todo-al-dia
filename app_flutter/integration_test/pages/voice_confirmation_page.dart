// integration_test/pages/voice_confirmation_page.dart
//
// Page Object for the voice confirmation screen.
// After voice input is processed, this screen shows the parsed result
// and lets the user confirm or edit before saving.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show find, Finder;
import 'package:patrol/patrol.dart';

Finder valueKey(String key) => find.byKey(ValueKey(key));

class VoiceConfirmationPage {
  VoiceConfirmationPage(this.$);

  final PatrolIntegrationTester $;

  String get confirmSaveKey => 'voice_confirm_save';

  /// Taps the confirm/save button to save the movement.
  Future<void> confirmSave() async {
    await $.tap(valueKey(confirmSaveKey));
    await $.pumpAndSettle();
  }

  /// Returns true if the confirm save button is visible.
  Future<bool> get isConfirmSaveVisible async {
    try {
      await $(valueKey(confirmSaveKey)).waitUntilVisible();
      return true;
    } catch (_) {
      return false;
    }
  }
}
