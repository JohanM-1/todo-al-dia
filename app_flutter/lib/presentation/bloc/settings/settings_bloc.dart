// lib/presentation/bloc/settings/settings_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/app_database.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AppDatabase _db;

  SettingsBloc({required AppDatabase db})
      : _db = db,
        super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeColor>(_onUpdateThemeColor);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateLanguage>(_onUpdateLanguage);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load theme color
      final themeColor = await _db.getThemeColor();

      // Load theme mode
      final themeModeStr = await _db.getSetting('theme_mode');
      ThemeMode themeMode = ThemeMode.system;
      if (themeModeStr == 'light') {
        themeMode = ThemeMode.light;
      } else if (themeModeStr == 'dark') {
        themeMode = ThemeMode.dark;
      }

      // Load language
      final languageCode = await _db.getLanguage();

      emit(state.copyWith(
        themeColor: themeColor ?? state.themeColor,
        themeMode: themeMode,
        languageCode: languageCode,
        isLoading: false,
        clearLanguageCode: languageCode == null || languageCode.isEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onUpdateThemeColor(
      UpdateThemeColor event, Emitter<SettingsState> emit) async {
    await _db.setThemeColor(event.color);
    emit(state.copyWith(themeColor: event.color));
  }

  Future<void> _onUpdateThemeMode(
      UpdateThemeMode event, Emitter<SettingsState> emit) async {
    String themeModeStr;
    switch (event.themeMode) {
      case ThemeMode.light:
        themeModeStr = 'light';
        break;
      case ThemeMode.dark:
        themeModeStr = 'dark';
        break;
      case ThemeMode.system:
        themeModeStr = 'system';
        break;
    }
    await _db.setSetting('theme_mode', themeModeStr);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onUpdateLanguage(
      UpdateLanguage event, Emitter<SettingsState> emit) async {
    if (event.languageCode == null) {
      await _db.deleteSetting('language');
    } else {
      await _db.setLanguage(event.languageCode!);
    }
    emit(state.copyWith(
      languageCode: event.languageCode,
      clearLanguageCode: event.languageCode == null,
    ));
  }
}
