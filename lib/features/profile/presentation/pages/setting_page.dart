import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/locale_manager.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
import 'package:xpensemate/features/profile/presentation/widgets/currency_dialog.dart';
import 'package:xpensemate/features/profile/presentation/widgets/language_dialog.dart';
import 'package:xpensemate/features/profile/presentation/widgets/settings_widgets.dart';
import 'package:xpensemate/features/profile/presentation/widgets/theme_dialog.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _transactionReminders = true;
  bool _budgetAlerts = true;
  bool _biometricAuth = false;
  String _selectedCurrency = 'USD';

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': r'$'},
    {'code': 'PKR', 'name': 'Pakistani Rupee', 'symbol': '₨'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': r'A$'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': r'C$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'Fr'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) => current is ProfileLoaded,
        builder: (context, state) {
          final loadedState = state is ProfileLoaded ? state : null;
          final themeMode = loadedState?.themeMode ?? ThemeMode.system;

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
                          _buildCurrencyTile(colorScheme, l10n),
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
                            value: _notificationsEnabled,
                            onChanged: (value) =>
                                setState(() => _notificationsEnabled = value),
                          ),
                          SettingsSwitchTile(
                            title: l10n.transactionReminders,
                            subtitle: l10n.transactionRemindersDesc,
                            icon: Icons.alarm,
                            value: _transactionReminders,
                            onChanged: (value) =>
                                setState(() => _transactionReminders = value),
                          ),
                          SettingsSwitchTile(
                            title: l10n.budgetAlerts,
                            subtitle: l10n.budgetAlertsDesc,
                            icon: Icons.warning_amber_outlined,
                            value: _budgetAlerts,
                            onChanged: (value) =>
                                setState(() => _budgetAlerts = value),
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
                            value: _biometricAuth,
                            onChanged: (value) =>
                                setState(() => _biometricAuth = value),
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
                            title: l10n.appVersion,
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
      ),
    );
  }

  Widget _buildCurrencyTile(ColorScheme colorScheme, AppLocalizations l10n) {
    final currency =
        _currencies.firstWhere((c) => c['code'] == _selectedCurrency);
    return SettingsBaseTile(
      title: l10n.currency,
      subtitle: '${currency['name']} (${currency['symbol']})',
      icon: Icons.attach_money,
      onTap: () => CurrencyDialog.show(
        context: context,
        selectedCurrency: _selectedCurrency,
        currencies: _currencies,
        onCurrencyChanged: (val) => setState(() => _selectedCurrency = val),
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
