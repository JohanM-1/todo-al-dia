// integration_test/pages/home_page.dart
//
// Page Object for the Home screen.
// Used in E2E tests to assert balance, empty state, and recent movements.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show find, Finder;
import 'package:patrol/patrol.dart';

Finder valueKey(String key) => find.byKey(ValueKey(key));

class HomePage {
  HomePage(this.$);

  final PatrolIntegrationTester $;

  String get fabKey => 'home_fab';
  String get emptyStateKey => 'home_empty_state';

  /// Returns true if the home empty state is visible.
  Future<bool> get isEmptyStateVisible async {
    try {
      await $(valueKey(emptyStateKey)).waitUntilVisible();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Taps the FAB to open the add movement form.
  Future<void> tapFab() async {
    await $.tap(valueKey(fabKey));
    await $.pumpAndSettle();
  }
}
