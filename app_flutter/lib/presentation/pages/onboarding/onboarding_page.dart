import 'dart:async';

// lib/presentation/pages/onboarding/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_card.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../widgets/page_hero_card.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final AppDatabase _db = AppDatabase.instance;
  final TextEditingController _currencySearchController =
      TextEditingController();

  int _currentPage = 0;
  String _selectedCurrency = AppConstants.defaultCurrency;
  String _accountName = '';
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_accountName.isEmpty) {
      _accountName = AppLocalizations.of(context)?.cashAccount ?? 'Cash';
    }
  }

  List<CurrencyInfo> get _filteredCurrencies {
    return CurrencyCatalog.search(_currencySearchController.text);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currencySearchController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      unawaited(_pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ));
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      unawaited(_pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ));
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Create default account
      final accountRepo = context.read<AccountRepository>();
      final account = AccountEntity(
        name: _accountName,
        currency: _selectedCurrency,
        createdAt: DateTime.now(),
      );
      await accountRepo.createAccount(account);

      // Mark onboarding as complete
      await _db.setSetting('onboarding_complete', 'true');
      await _db.setSetting('currency', _selectedCurrency);

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final isTablet = constraints.maxWidth >= 600;
            final maxWidth =
                isWide ? 560.0 : (isTablet ? 500.0 : double.infinity);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassCard(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: Column(
                        children: [
                          _buildProgressIndicator(),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (index) {
                                setState(() => _currentPage = index);
                              },
                              children: [
                                _buildWelcomePage(),
                                _buildCurrencyPage(),
                                _buildAccountPage(),
                              ],
                            ),
                          ),
                          _buildNavigationButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TextButton(
            key: const ValueKey('onboarding_skip'),
            onPressed: _completeOnboarding,
            child: Text(l10n.onboardingSkip),
          ),
          const Spacer(),
          ...List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: index <= _currentPage
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: PageHeroCard(
          eyebrow: l10n.onboardingWelcomeEyebrow,
          title: l10n.onboardingWelcomeTitle,
          subtitle: l10n.onboardingWelcomeSubtitle,
          icon: Icons.account_balance_wallet_rounded,
          footer: [
            _buildFeatureChip(Icons.mic_rounded, l10n.onboardingVoiceFeature),
            _buildFeatureChip(
              Icons.pie_chart_rounded,
              l10n.onboardingBudgetsFeature,
            ),
            _buildFeatureChip(
              Icons.savings_rounded,
              l10n.onboardingGoalsFeature,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _buildCurrencyPage() {
    final l10n = AppLocalizations.of(context)!;
    final selectedCurrencyInfo = CurrencyCatalog.getByCode(_selectedCurrency) ??
        CurrencyCatalog.defaultCurrency;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingCurrencyTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingCurrencySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Text(selectedCurrencyInfo.flagEmoji),
                label: Text(selectedCurrencyInfo.displayLabel),
              ),
              Chip(
                label: Text(l10n.onboardingCurrencyDefaultHint),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _currencySearchController,
            decoration: InputDecoration(
              hintText: l10n.searchByNameOrCode,
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredCurrencies.isEmpty
                ? Center(
                    child: Text(
                      l10n.noCurrenciesFound,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      final isSelected = currency.code == _selectedCurrency;
                      return GlassCard(
                        key: ValueKey('onboarding_currency_${currency.code}'),
                        margin: const EdgeInsets.only(bottom: 8),
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            child: Text(
                              currency.flagEmoji,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(currency.name),
                          subtitle: Text(currency.selectorSubtitle),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCurrency = currency.code;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPage() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingAccountTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingAccountSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('onboarding_account_name'),
                    initialValue: _accountName,
                    decoration: InputDecoration(
                      labelText: l10n.accountName,
                      prefixIcon: Icon(Icons.edit),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _accountName = value.isEmpty ? l10n.cashAccount : value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.selectedCurrencyLabel),
                        Text(
                          '${CurrencyCatalog.getSymbol(_selectedCurrency)} $_selectedCurrency',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.onboardingAccountTip,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton(
              key: const ValueKey('onboarding_back'),
              onPressed: _previousPage,
              child: Text(l10n.back),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          if (_currentPage < 2)
            FilledButton(
              key: const ValueKey('onboarding_next'),
              onPressed: _nextPage,
              child: Text(l10n.continueLabel),
            )
          else
            FilledButton(
              key: const ValueKey('onboarding_create_account'),
              onPressed: _isLoading ? null : _completeOnboarding,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.start),
            ),
        ],
      ),
    );
  }
}
