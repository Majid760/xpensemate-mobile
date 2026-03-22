import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/locale_manager.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
import 'package:xpensemate/features/profile/presentation/widgets/currency_dialog.dart';
import 'package:xpensemate/features/profile/presentation/widgets/language_dialog.dart';
import 'package:xpensemate/features/profile/presentation/widgets/settings_widgets.dart';
import 'package:xpensemate/features/profile/presentation/widgets/theme_dialog.dart';
import 'package:xpensemate/features/settings/domain/entities/settings_entity.dart';
import 'package:xpensemate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:xpensemate/features/settings/presentation/cubit/settings_state.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Resolves the localized display name for [code] from [SettingsCubit.currencies].
  String _currencyName(String code, AppLocalizations l10n) => switch (code) {
      'USD' => l10n.currencyUSD,
      'PKR' => l10n.currencyPKR,
      'EUR' => l10n.currencyEUR,
      'GBP' => l10n.currencyGBP,
      'JPY' => l10n.currencyJPY,
      'AUD' => l10n.currencyAUD,
      'CAD' => l10n.currencyCAD,
      'CHF' => l10n.currencyCHF,
      'CNY' => l10n.currencyCNY,
      'INR' => l10n.currencyINR,
      _ => code,
    };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous is SettingsLoaded && current is SettingsLoaded
              ? previous.message != current.message
              : current is SettingsError,
      listener: (context, state) {
        if (state is SettingsLoaded && state.message != null) {
          AppSnackBar.show(
            context: context,
            message: state.message!,
            type: SnackBarType.success,
          );
        } else if (state is SettingsError) {
          AppSnackBar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (previous, current) => current is ProfileLoaded,
          builder: (context, state) {
            final loadedState = state is ProfileLoaded ? state : null;
            final themeMode = loadedState?.themeMode ?? ThemeMode.system;

            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final settings = settingsState is SettingsLoaded
                    ? settingsState.settings
                    : const SettingsEntity();

              return CustomScrollView(
            slivers: [
              _SettingsAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsSection(
                        title: l10n.preferences,
                        children: [
                          SettingsBaseTile(
                            title: l10n.language,
                            subtitle: SupportedLocales.getDisplayName(
                              LocaleManager().currentLocale,
                            ),
                            icon: Icons.language,
                            onTap: () => LanguageDialog.show(
                              context: context,
                              currentLocale: LocaleManager().currentLocale,
                              onLanguageChanged: (locale) =>
                                  LocaleManager().setLocale(locale),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          _buildCurrencyTile(colorScheme, l10n, settings.selectedCurrency),
                          _buildThemeTile(themeMode, colorScheme, l10n),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SettingsSection(
                        title: l10n.notifications,
                        children: [
                          SettingsSwitchTile(
                            title: l10n.notifications,
                            subtitle: l10n.receiveNotificationsDesc,
                            icon: Icons.notifications_outlined,
                            value: settings.notificationsEnabled,
                            onChanged: (value) => context.settingsCubit
                                .updateSettings(notificationsEnabled: value),
                          ),
                          SettingsSwitchTile(
                            title: l10n.transactionReminders,
                            subtitle: l10n.transactionRemindersDesc,
                            icon: Icons.alarm,
                            value: settings.transactionReminders,
                            onChanged: (value) => context.settingsCubit
                                .updateSettings(transactionReminders: value),
                          ),
                          SettingsSwitchTile(
                            title: l10n.budgetAlerts,
                            subtitle: l10n.budgetAlertsDesc,
                            icon: Icons.warning_amber_outlined,
                            value: settings.budgetAlerts,
                            onChanged: (value) => context.settingsCubit
                                .updateSettings(budgetAlerts: value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SettingsSection(
                        title: l10n.privacySecurity,
                        children: [
                          SettingsSwitchTile(
                            title: l10n.biometricAuth,
                            subtitle: l10n.useFingerprintOrFaceId,
                            icon: Icons.fingerprint,
                            value: settings.biometricAuth,
                            onChanged: (value) => context.settingsCubit
                                .updateSettings(biometricAuth: value),
                          ),
                          SettingsNavigationTile(
                            title: l10n.appPermissions,
                            subtitle: l10n.appPermissionsDesc,
                            icon: Icons.security,
                            onTap: () =>
                                AppDialogs.showPermissionManagementDialog(
                              context,
                            ),
                          ),
                          // SettingsNavigationTile(
                          //   title: l10n.changePin,
                          //   subtitle: l10n.changePinDesc,
                          //   icon: Icons.pin_outlined,
                          //   onTap: () {},
                          // ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SettingsSection(
                        title: l10n.dataManagement,
                        children: [
                          // SettingsSwitchTile(
                          //   title: l10n.autoBackup,
                          //   subtitle: l10n.autoBackupDesc,
                          //   icon: Icons.backup_outlined,
                          //   value: _autoBackup,
                          //   onChanged: (value) =>
                          //       setState(() => _autoBackup = value),
                          // ),
                          SettingsNavigationTile(
                            title: l10n.exportData,
                            subtitle: l10n.exportDataDesc,
                            icon: Icons.download_outlined,
                            onTap: () {},
                          ),
                          SettingsNavigationTile(
                            title: l10n.importData,
                            subtitle: l10n.importDataDesc,
                            icon: Icons.upload_outlined,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SettingsSection(
                        title: l10n.budgetAndCategories,
                        children: [
                          // SettingsNavigationTile(
                          //   title: l10n.defaultCategories,
                          //   subtitle: l10n.manageCategoriesDesc,
                          //   icon: Icons.category_outlined,
                          //   onTap: () {},
                          // ),
                          SettingsNavigationTile(
                            title: l10n.budgetPeriod,
                            subtitle: l10n.setBudgetCycleDesc,
                            icon: Icons.calendar_today_outlined,
                            onTap: () {},
                          ),
                          SettingsNavigationTile(
                            title: l10n.recurringTransactions,
                            subtitle: l10n.manageRecurringDesc,
                            icon: Icons.repeat,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SettingsSection(
                        title: l10n.about,
                        children: [
                          SettingsNavigationTile(
                            title: l10n.helpSupport,
                            subtitle: l10n.getHelpWhenNeeded,
                            icon: Icons.help_outline,
                            onTap: () {},
                          ),
                          SettingsNavigationTile(
                            title: l10n.privacyPolicy,
                            subtitle: l10n.privacyPolicyDesc,
                            icon: Icons.privacy_tip_outlined,
                            onTap: () {},
                          ),
                          SettingsNavigationTile(
                            title: l10n.termsOfService,
                            subtitle: l10n.termsOfServiceDesc,
                            icon: Icons.description_outlined,
                            onTap: () {},
                          ),
                          SettingsInfoTile(
                            title: l10n.appVersionTitle,
                            value: '1.0.0',
                            icon: Icons.info_outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      DangerZone(
                        title: l10n.clearAllData,
                        subtitle: l10n.clearAllDataDesc,
                        onTap: () => AppCustomDialogs.showConfirmation(
                          context: context,
                          title: l10n.delete,
                          message: l10n.clearAllDataDesc,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
              );
            },
          );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyTile(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    String selectedCurrency,
  ) {
    const currencies = SettingsCubit.currencies;
    final currency = currencies.firstWhere((c) => c['code'] == selectedCurrency);
    final name = _currencyName(selectedCurrency, l10n);
    return SettingsBaseTile(
      title: l10n.currency,
      subtitle: '$name (${currency['symbol']})',
      icon: Icons.attach_money,
      onTap: () => CurrencyDialog.show(
        context: context,
        selectedCurrency: selectedCurrency,
        currencies: currencies
            .map((c) => {
                  'code': c['code']!,
                  'name': _currencyName(c['code']!, l10n),
                  'symbol': c['symbol']!,
                },)
            .toList(),
        onCurrencyChanged: (val) =>
            context.settingsCubit.updateSettings(selectedCurrency: val),
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildThemeTile(
    ThemeMode themeMode,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    String themeText;
    switch (themeMode) {
      case ThemeMode.light:
        themeText = l10n.lightTheme;
        break;
      case ThemeMode.dark:
        themeText = l10n.darkTheme;
        break;
      case ThemeMode.system:
        themeText = l10n.systemTheme;
        break;
    }
    return SettingsBaseTile(
      title: l10n.themeMode,
      subtitle: themeText,
      icon: Icons.palette_outlined,
      onTap: () => ThemeDialog.show(
        context: context,
        currentTheme: themeMode,
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
    );
  }
}

class _SettingsAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SliverAppBar.large(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          context.l10n.settings,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.tertiary],
            ),
          ),
        ),
      ),
    );
  }
}
