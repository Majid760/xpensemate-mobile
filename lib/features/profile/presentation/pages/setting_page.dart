import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';

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
  bool _autoBackup = true;
  final String _selectedLanguage = 'English';
  final String _selectedCurrency = 'USD';

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
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) => current is ProfileLoaded,
        builder: (context, state) {
          final loadedState = state is ProfileLoaded ? state : null;
          final themeMode = loadedState?.themeMode ?? ThemeMode.system;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                expandedHeight: 120,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    context.l10n.settings,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.tertiary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context.l10n.preferences),
                      const SizedBox(height: 8),
                      _buildSettingsCard([
                        _buildLanguageTile(),
                        _buildDivider(),
                        _buildCurrencyTile(),
                        _buildDivider(),
                        _buildThemeTile(themeMode),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context.l10n.notifications),
                      const SizedBox(height: 8),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          'Enable Notifications',
                          'Receive app notifications',
                          Icons.notifications_outlined,
                          _notificationsEnabled,
                          (value) =>
                              setState(() => _notificationsEnabled = value),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          'Transaction Reminders',
                          'Daily reminder to log expenses',
                          Icons.alarm,
                          _transactionReminders,
                          (value) =>
                              setState(() => _transactionReminders = value),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          'Budget Alerts',
                          'Alert when approaching budget limit',
                          Icons.warning_amber_outlined,
                          _budgetAlerts,
                          (value) => setState(() => _budgetAlerts = value),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context.l10n.privacySecurity),
                      const SizedBox(height: 8),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          'Biometric Authentication',
                          'Use fingerprint or face ID',
                          Icons.fingerprint,
                          _biometricAuth,
                          (value) => setState(() => _biometricAuth = value),
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'App Permissions',
                          'Manage app access permissions',
                          Icons.security,
                          _showPermissionsDialog,
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'Change PIN',
                          'Update your security PIN',
                          Icons.pin_outlined,
                          () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Data Management'),
                      const SizedBox(height: 8),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          'Auto Backup',
                          'Automatically backup data daily',
                          Icons.backup_outlined,
                          _autoBackup,
                          (value) => setState(() => _autoBackup = value),
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'Export Data',
                          'Download your data as CSV or PDF',
                          Icons.download_outlined,
                          () {},
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'Import Data',
                          'Import transactions from file',
                          Icons.upload_outlined,
                          () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Budget & Categories'),
                      const SizedBox(height: 8),
                      _buildSettingsCard([
                        _buildNavigationTile(
                          'Default Categories',
                          'Manage expense categories',
                          Icons.category_outlined,
                          () {},
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'Budget Period',
                          'Set monthly or custom budget cycle',
                          Icons.calendar_today_outlined,
                          () {},
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'Recurring Transactions',
                          'Manage recurring expenses and income',
                          Icons.repeat,
                          () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context.l10n.about),
                      const SizedBox(height: 8),
                      _buildSettingsCard([
                        _buildNavigationTile(
                          context.l10n.helpSupport,
                          'Get help or contact support',
                          Icons.help_outline,
                          () {},
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'Privacy Policy',
                          'Read our privacy policy',
                          Icons.privacy_tip_outlined,
                          () {},
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          'Terms of Service',
                          'View terms and conditions',
                          Icons.description_outlined,
                          () {},
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          'App Version',
                          '1.0.0',
                          Icons.info_outline,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildDangerZone(),
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

  Widget _buildSectionTitle(String title) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    final colorScheme = context.colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final colorScheme = context.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = context.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    final colorScheme = context.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    final colorScheme = context.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.language, color: colorScheme.primary, size: 24),
      ),
      title: Text(
        context.l10n.language,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        _selectedLanguage,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildCurrencyTile() {
    final colorScheme = context.colorScheme;
    final currency =
        _currencies.firstWhere((c) => c['code'] == _selectedCurrency);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.attach_money, color: colorScheme.primary, size: 24),
      ),
      title: const Text(
        'Currency',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        '${currency['name']} (${currency['symbol']})',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: _showCurrencyDialog,
    );
  }

  Widget _buildThemeTile(ThemeMode themeMode) {
    final colorScheme = context.colorScheme;
    String themeText;
    switch (themeMode) {
      case ThemeMode.light:
        themeText = context.l10n.lightTheme;
        break;
      case ThemeMode.dark:
        themeText = context.l10n.darkTheme;
        break;
      case ThemeMode.system:
        themeText = context.l10n.systemTheme;
        break;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Icon(Icons.palette_outlined, color: colorScheme.primary, size: 24),
      ),
      title: Text(
        context.l10n.themeMode,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        themeText,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showThemeDialog(themeMode),
    );
  }

  Widget _buildDangerZone() {
    final colorScheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline,
                  color: colorScheme.error, size: 24),
            ),
            title: Text(
              'Clear All Data',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: colorScheme.error,
              ),
            ),
            subtitle: const Text(
              'Delete all transactions and reset app',
              style: TextStyle(fontSize: 13),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.error,
            ),
            onTap: _showDeleteConfirmation,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'English',
            'اردو (Urdu)',
            'العربية (Arabic)',
            'Español (Spanish)',
            'Français (French)',
            '中文 (Chinese)',
          ]
              .map((lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: _selectedLanguage,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      // setState(() => _selectedLanguage = value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final currency = _currencies[index];
              return RadioListTile<String>(
                title: Text('${currency['name']}'),
                subtitle: Text('${currency['code']} (${currency['symbol']})'),
                value: currency['code']!,
                groupValue: _selectedCurrency,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  // setState(() => _selectedCurrency = value!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(ThemeMode currentTheme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.themeMode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeMode.light,
            ThemeMode.dark,
            ThemeMode.system,
          ].map((mode) {
            String title;
            switch (mode) {
              case ThemeMode.light:
                title = context.l10n.lightTheme;
                break;
              case ThemeMode.dark:
                title = context.l10n.darkTheme;
                break;
              case ThemeMode.system:
                title = context.l10n.systemTheme;
                break;
            }
            return RadioListTile<ThemeMode>(
              title: Text(title),
              value: mode,
              groupValue: currentTheme,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                if (value != null) {
                  context.read<ProfileCubit>().updateTheme(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Permissions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPermissionItem('Camera', 'Allowed', true),
            _buildPermissionItem('Storage', 'Allowed', true),
            _buildPermissionItem('Notifications', 'Allowed', true),
            _buildPermissionItem('Biometrics', 'Not Allowed', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String name, String status, bool allowed) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle : Icons.cancel,
            color: allowed
                ? AppColors.success
                : colorScheme.error, // Keeping success, standardizing error
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your transactions, budgets, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
