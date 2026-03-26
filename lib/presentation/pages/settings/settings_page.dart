import 'dart:async';

// lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/currency_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/app_database.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppDatabase _db = AppDatabase.instance;
  String _currency = 'ARS';

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    final currency = await _db.getSetting('currency');
    if (mounted) {
      setState(() {
        _currency = currency ?? 'ARS';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontalPadding = isWide ? 24.0 : 16.0;
            final maxContentWidth = isWide ? 600.0 : double.infinity;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Configuración'),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: ListView(
                      children: [
                        const _SectionHeader(title: 'General'),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text('Moneda'),
                          subtitle: Text(_currency),
                          onTap: _showCurrencyPicker,
                        ),
                        ListTile(
                          leading: const Icon(Icons.palette),
                          title: const Text('Tema'),
                          subtitle: Text(_getThemeName(state.themeMode)),
                          onTap: () =>
                              _showThemePicker(context, state.themeMode),
                        ),
                        ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: state.themeColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                          title: const Text('Color del tema'),
                          subtitle: const Text('Seleccionar color'),
                          onTap: () =>
                              _showColorPicker(context, state.themeColor),
                        ),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Idioma'),
                          subtitle: Text(_getLanguageName(state.languageCode)),
                          onTap: () =>
                              _showLanguagePicker(context, state.languageCode),
                        ),
                        const Divider(),
                        const _SectionHeader(title: 'Datos'),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Categorías'),
                          subtitle: const Text('Gestionar categorías'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/settings/categories'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.file_download),
                          title: const Text('Exportar movimientos'),
                          subtitle: const Text('Exportar a CSV'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/settings/export'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          title: const Text('Borrar todos los datos'),
                          subtitle: const Text('Eliminar todo el historial'),
                          onTap: () => _showDeleteConfirmation(context),
                        ),
                        const Divider(),
                        const _SectionHeader(title: 'Acerca de'),
                        const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Versión'),
                          subtitle: Text('0.1.0'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Términos y privacidad'),
                          onTap: () {
                            // TODO: Open privacy policy
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  String _getLanguageName(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) {
      return 'Automático';
    }
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'Inglés';
      default:
        return 'Automático';
    }
  }

  Future<void> _showCurrencyPicker() async {
    final currencies = CurrencyCatalog.forSelector;

    await showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Seleccionar moneda'),
        children: currencies.map((c) {
          return SimpleDialogOption(
            onPressed: () async {
              await _db.setSetting('currency', c.code);
              if (!context.mounted) {
                return;
              }

              if (mounted) {
                setState(() => _currency = c.code);
                Navigator.pop(context);
              }
            },
            child: ListTile(
              leading: CircleAvatar(child: Text(c.symbol)),
              title: Text(c.name),
              subtitle: Text(c.code),
              selected: _currency == c.code,
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showThemePicker(
      BuildContext context, ThemeMode currentMode) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Seleccionar tema'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              context
                  .read<SettingsBloc>()
                  .add(const UpdateThemeMode(ThemeMode.system));
              Navigator.pop(dialogContext);
            },
            child: ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('Sistema'),
              selected: currentMode == ThemeMode.system,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              context
                  .read<SettingsBloc>()
                  .add(const UpdateThemeMode(ThemeMode.light));
              Navigator.pop(dialogContext);
            },
            child: ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Claro'),
              selected: currentMode == ThemeMode.light,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              context
                  .read<SettingsBloc>()
                  .add(const UpdateThemeMode(ThemeMode.dark));
              Navigator.pop(dialogContext);
            },
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Oscuro'),
              selected: currentMode == ThemeMode.dark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(
      BuildContext context, Color currentColor) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Seleccionar color'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.themeColorOptions.map((color) {
                final isSelected = color.toARGB32() == currentColor.toARGB32();
                return GestureDetector(
                  onTap: () {
                    context.read<SettingsBloc>().add(UpdateThemeColor(color));
                    Navigator.pop(dialogContext);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguagePicker(
      BuildContext context, String? currentLanguage) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Seleccionar idioma'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              context.read<SettingsBloc>().add(const UpdateLanguage(null));
              Navigator.pop(dialogContext);
            },
            child: ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Automático'),
              selected: currentLanguage == null || currentLanguage.isEmpty,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              context.read<SettingsBloc>().add(const UpdateLanguage('es'));
              Navigator.pop(dialogContext);
            },
            child: ListTile(
              leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
              title: const Text('Español'),
              selected: currentLanguage == 'es',
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              context.read<SettingsBloc>().add(const UpdateLanguage('en'));
              Navigator.pop(dialogContext);
            },
            child: ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('Inglés'),
              selected: currentLanguage == 'en',
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todos los datos?'),
        content: const Text(
          'Esta acción eliminará todos los movimientos, presupuestos y metas. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos eliminados')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
