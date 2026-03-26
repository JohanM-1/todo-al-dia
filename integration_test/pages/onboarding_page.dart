// integration_test/pages/onboarding_page.dart
//
// Page Object for the onboarding flow.
// Uses stable ValueKey selectors defined in lib/presentation/pages/onboarding/.
//
// Selector approach: find.byKey(ValueKey('key_string')) from flutter_test,
// used with Patrol's $(finder) wrapper for automatic waiting.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show find, Finder;
import 'package:patrol/patrol.dart';

/// Resolves a ValueKey string to a Flutter Finder by Key.
/// Usage: $(valueKey('my_key')).waitUntilVisible()
Finder valueKey(String key) => find.byKey(ValueKey(key));

class OnboardingPage {
  OnboardingPage(this.$);

  final PatrolIntegrationTester $;

  // --- Key strings (stable, must match lib/) ---

  String get skipKey => 'onboarding_skip';
  String get backKey => 'onboarding_back';
  String get nextKey => 'onboarding_next';
  String get createAccountKey => 'onboarding_create_account';
  String get accountNameKey => 'onboarding_account_name';

  /// Currency card key for a given currency code.
  String currencyCardKey(String code) => 'onboarding_currency_$code';

  // --- Actions ---

  /// Skips onboarding: tap skip → enter account name → create account.
  Future<void> skipOnboarding({String accountName = 'Test Account'}) async {
    await $.tap(valueKey(skipKey));
    await $.pumpAndSettle();
    // Skip lands on account creation page.
    await $.enterText(valueKey(accountNameKey), accountName);
    await $.pumpAndSettle();
    await $.tap(valueKey(createAccountKey));
    await $.pumpAndSettle();
  }

  /// Completes the full onboarding flow: next through all pages and creates account.
  Future<void> completeOnboarding({
    String accountName = 'Test Account',
    String currencyCode = 'ARS',
  }) async {
    // Page 0 → page 1
    await $.tap(valueKey(nextKey));
    await $.pumpAndSettle();

    // Page 1: select currency
    await $.tap(valueKey(currencyCardKey(currencyCode)));
    await $.pumpAndSettle();

    // Page 1 → page 2
    await $.tap(valueKey(nextKey));
    await $.pumpAndSettle();

    // Page 2: enter account name
    await $.enterText(valueKey(accountNameKey), accountName);
    await $.pumpAndSettle();

    // Create account
    await $.tap(valueKey(createAccountKey));
    await $.pumpAndSettle();
  }

  /// Returns true if onboarding skip button is visible (app is on onboarding).
  Future<bool> get isSkipVisible async {
    try {
      await $(valueKey(skipKey)).waitUntilVisible();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if create account button is visible (on account creation page).
  Future<bool> get isCreateAccountVisible async {
    try {
      await $(valueKey(createAccountKey)).waitUntilVisible();
      return true;
    } catch (_) {
      return false;
    }
  }
}
