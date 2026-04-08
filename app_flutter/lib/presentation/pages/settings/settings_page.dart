import 'dart:async';

// lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_card.dart';
import '../../../data/database/app_database.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';
import '../../widgets/page_hero_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppDatabase _db = AppDatabase.instance;
  String _currency = AppConstants.defaultCurrency;
  String _appVersion = '...';

  CurrencyInfo get _selectedCurrencyInfo =>
      CurrencyCatalog.getByCode(_currency) ?? CurrencyCatalog.defaultCurrency;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
    unawaited(_loadAppVersion());
  }

  Future<void> _loadSettings() async {
    final currency = await _db.getSetting('currency');
    if (mounted) {
      setState(() {
        _currency = CurrencyCatalog.normalizeCode(currency);
      });
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildNumber = packageInfo.buildNumber.trim();
      final version = packageInfo.version.trim();
      final formattedVersion =
          buildNumber.isEmpty ? version : '$version+$buildNumber';

      if (mounted) {
        setState(() {
          _appVersion = formattedVersion;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _appVersion = AppLocalizations.of(context)?.unavailable ?? 'N/A';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontalPadding = isWide ? 24.0 : 16.0;
            final maxContentWidth = isWide ? 600.0 : double.infinity;

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.configuration),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: ListView(
                      children: [
                        PageHeroCard(
                          eyebrow: l10n.settingsHeroEyebrow,
                          title: l10n.settingsHeroTitle,
                          subtitle: l10n.settingsHeroSubtitle,
                          icon: Icons.tune_rounded,
                          footer: [
                            HeroBadge(
                              label: _currency,
                              color: Theme.of(context).colorScheme.primary,
                              leading: Text(
                                _selectedCurrencyInfo.flagEmoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            HeroBadge(
                              label: _getThemeName(context, state.themeMode),
                              color: state.themeColor,
                              icon: Icons.palette_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _SectionHeader(title: l10n.general),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 14,
                                  child: Text(_selectedCurrencyInfo.flagEmoji),
                                ),
                                title: Text(l10n.currency),
                                subtitle: Text(
                                  _selectedCurrencyInfo.displayLabel,
                                ),
                                onTap: _showCurrencyPicker,
                              ),
                              ListTile(
                                leading: const Icon(Icons.palette),
                                title: Text(l10n.theme),
                                subtitle: Text(
                                  _getThemeName(context, state.themeMode),
                                ),
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
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                                title: Text(l10n.themeColor),
                                subtitle: Text(l10n.selectThemeColor),
                                onTap: () =>
                                    _showColorPicker(context, state.themeColor),
                              ),
                              ListTile(
                                leading: const Icon(Icons.language),
                                title: Text(l10n.language),
                                subtitle: Text(_getLanguageName(
                                    context, state.languageCode)),
                                onTap: () => _showLanguagePicker(
                                  context,
                                  state.languageCode,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(title: l10n.data),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.category),
                                title: Text(l10n.categories),
                                subtitle: Text(l10n.manageCategories),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () =>
                                    context.push('/settings/categories'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.file_download),
                                title: Text(l10n.exportMovements),
                                subtitle: Text(l10n.exportToCSV),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/settings/export'),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                title: Text(l10n.deleteAllData),
                                subtitle: Text(l10n.deleteAllDataSubtitle),
                                onTap: () => _showDeleteConfirmation(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(title: l10n.about),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: Text(l10n.version),
                                subtitle: Text(_appVersion),
                              ),
                              ListTile(
                                leading: const Icon(Icons.privacy_tip_outlined),
                                title: Text(l10n.privacy),
                                subtitle: Text(l10n.privacySubtitle),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _showPrivacySheet(context),
                              ),
                            ],
                          ),
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

  String _getThemeName(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;

    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }

  String _getLanguageName(BuildContext context, String? languageCode) {
    final l10n = AppLocalizations.of(context)!;

    if (languageCode == null || languageCode.isEmpty) {
      return l10n.auto;
    }
    switch (languageCode) {
      case 'es':
        return l10n.spanish;
      case 'en':
        return l10n.english;
      default:
        return l10n.auto;
    }
  }

  Future<void> _showCurrencyPicker() async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var filteredCurrencies = CurrencyCatalog.forSelector;

        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectCurrency,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l10n.searchByNameOrCode,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        setDialogState(() {
                          filteredCurrencies = CurrencyCatalog.search(query);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredCurrencies.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noCurrenciesFound,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCurrencies.length,
                              itemBuilder: (context, index) {
                                final currency = filteredCurrencies[index];
                                final isSelected = _currency == currency.code;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    child: Text(currency.flagEmoji),
                                  ),
                                  title: Text(currency.name),
                                  subtitle: Text(currency.selectorSubtitle),
                                  selected: isSelected,
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        )
                                      : null,
                                  onTap: () async {
                                    await _db.setSetting(
                                      'currency',
                                      currency.code,
                                    );
                                    if (!dialogContext.mounted) {
                                      return;
                                    }

                                    if (mounted) {
                                      setState(() => _currency = currency.code);
                                    }

                                    Navigator.pop(dialogContext);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showThemePicker(
      BuildContext context, ThemeMode currentMode) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectTheme),
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
              title: Text(l10n.system),
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
              title: Text(l10n.light),
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
              title: Text(l10n.dark),
              selected: currentMode == ThemeMode.dark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(
      BuildContext context, Color currentColor) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectColor),
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
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () {
              context.read<SettingsBloc>().add(const UpdateLanguage(null));
              Navigator.pop(dialogContext);
            },
            child: ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(l10n.auto),
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
              title: Text(l10n.spanish),
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
              title: Text(l10n.english),
              selected: currentLanguage == 'en',
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    unawaited(showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDataConfirm),
        content: Text(l10n.deleteDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.dataDeleted)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    ));
  }

  void _showPrivacySheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    unawaited(showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.privacyTitle(AppConstants.appName),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.privacyIntro,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _PrivacyPoint(
                icon: Icons.storage_rounded,
                title: l10n.privacyLocalDataTitle,
                description: l10n.privacyLocalDataDescription,
              ),
              const SizedBox(height: 12),
              _PrivacyPoint(
                icon: Icons.mic_none_rounded,
                title: l10n.privacyMicrophoneTitle,
                description: l10n.privacyMicrophoneDescription,
              ),
              const SizedBox(height: 12),
              _PrivacyPoint(
                icon: Icons.file_download_outlined,
                title: l10n.privacyExportsTitle,
                description: l10n.privacyExportsDescription,
              ),
              const SizedBox(height: 12),
              _PrivacyPoint(
                icon: Icons.shield_outlined,
                title: l10n.privacyNoSyncTitle,
                description: l10n.privacyNoSyncDescription,
              ),
            ],
          ),
        ),
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
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrivacyPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}
