// test/presentation/bloc/settings/settings_bloc_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaldia/data/database/app_database.dart';
import 'package:todoaldia/presentation/bloc/settings/settings_bloc.dart';
import 'package:todoaldia/presentation/bloc/settings/settings_event.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDb;
  late SettingsBloc settingsBloc;

  setUp(() {
    mockDb = MockAppDatabase();
    settingsBloc = SettingsBloc(db: mockDb);
  });

  tearDown(() async {
    await settingsBloc.close();
  });

  group('SettingsBloc', () {
    test('initial state is correct', () {
      expect(settingsBloc.state.themeColor, const Color(0xFF2ECC71));
      expect(settingsBloc.state.themeMode, ThemeMode.system);
      expect(settingsBloc.state.languageCode, isNull);
      expect(settingsBloc.state.isLoading, false);
    });

    test('UpdateThemeColor changes theme color', () async {
      // Arrange
      const newColor = Color(0xFF702ECC);
      when(() => mockDb.setThemeColor(newColor)).thenAnswer((_) async {});

      // Act
      settingsBloc.add(const UpdateThemeColor(newColor));

      // Assert - wait for async to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(settingsBloc.state.themeColor, newColor);
    });

    test('UpdateThemeMode changes theme mode to dark', () async {
      // Arrange
      when(() => mockDb.setSetting('theme_mode', 'dark'))
          .thenAnswer((_) async {});

      // Act
      settingsBloc.add(const UpdateThemeMode(ThemeMode.dark));

      // Assert
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(settingsBloc.state.themeMode, ThemeMode.dark);
    });

    test('UpdateThemeMode changes theme mode to light', () async {
      // Arrange
      when(() => mockDb.setSetting('theme_mode', 'light'))
          .thenAnswer((_) async {});

      // Act
      settingsBloc.add(const UpdateThemeMode(ThemeMode.light));

      // Assert
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(settingsBloc.state.themeMode, ThemeMode.light);
    });

    test('UpdateLanguage with valid code sets language', () async {
      // Arrange
      when(() => mockDb.setLanguage('es')).thenAnswer((_) async {});

      // Act
      settingsBloc.add(const UpdateLanguage('es'));

      // Assert
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(settingsBloc.state.languageCode, 'es');
    });

    test('UpdateLanguage with null clears language', () async {
      // Arrange
      when(() => mockDb.deleteSetting('language')).thenAnswer((_) async {});

      // Act
      settingsBloc.add(const UpdateLanguage(null));

      // Assert
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(settingsBloc.state.languageCode, isNull);
    });
  });
}
