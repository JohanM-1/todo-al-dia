// lib/presentation/bloc/settings/settings_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Color themeColor;
  final ThemeMode themeMode;
  final String? languageCode; // null = auto-detect
  final bool isLoading;

  const SettingsState({
    this.themeColor = const Color(0xFF2ECC71), // Brand green
    this.themeMode = ThemeMode.system,
    this.languageCode,
    this.isLoading = false,
  });

  SettingsState copyWith({
    Color? themeColor,
    ThemeMode? themeMode,
    String? languageCode,
    bool? isLoading,
    bool clearLanguageCode = false,
  }) {
    return SettingsState(
      themeColor: themeColor ?? this.themeColor,
      themeMode: themeMode ?? this.themeMode,
      languageCode:
          clearLanguageCode ? null : (languageCode ?? this.languageCode),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeColor, themeMode, languageCode, isLoading];
}
