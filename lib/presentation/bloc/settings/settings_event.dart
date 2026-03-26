// lib/presentation/bloc/settings/settings_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateThemeColor extends SettingsEvent {
  final Color color;

  const UpdateThemeColor(this.color);

  @override
  List<Object?> get props => [color];
}

class UpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateLanguage extends SettingsEvent {
  final String? languageCode; // null = auto-detect

  const UpdateLanguage(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}
