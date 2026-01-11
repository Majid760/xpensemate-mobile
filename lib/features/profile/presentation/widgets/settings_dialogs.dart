import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';

class SettingsDialogs {
  static void showLanguageDialog(
    BuildContext context,
    String selectedLanguage,
    ValueChanged<String> onLanguageChanged,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.selectLanguage),
        content: RadioGroup<String>(
          groupValue: selectedLanguage,
          onChanged: (value) {
            if (value != null) onLanguageChanged(value);
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'English',
              'اردو (Urdu)',
              'العربية (Arabic)',
              'Español (Spanish)',
              'Français (French)',
              '中文 (Chinese)',
            ]
                .map(
                  (lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  static void showCurrencyDialog(
    BuildContext context,
    String selectedCurrency,
    List<Map<String, String>> currencies,
    ValueChanged<String> onCurrencyChanged,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.selectCurrency),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: selectedCurrency,
            onChanged: (value) {
              if (value != null) onCurrencyChanged(value);
              Navigator.pop(context);
            },
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                return RadioListTile<String>(
                  title: Text('${currency['name']}'),
                  subtitle: Text('${currency['code']} (${currency['symbol']})'),
                  value: currency['code']!,
                  activeColor: Theme.of(context).colorScheme.primary,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static void showThemeDialog(BuildContext context, ThemeMode currentTheme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.themeMode),
        content: RadioGroup<ThemeMode>(
          groupValue: currentTheme,
          onChanged: (value) {
            if (value != null) {
              context.read<ProfileCubit>().updateTheme(value);
            }
            Navigator.pop(context);
          },
          child: Column(
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
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  static void showPermissionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.appPermissions),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PermissionItem(
              name: context.l10n.camera,
              status: context.l10n.allowed,
              allowed: true,
            ),
            _PermissionItem(
              name: context.l10n.storage,
              status: context.l10n.allowed,
              allowed: true,
            ),
            _PermissionItem(
              name: context.l10n.notifications,
              status: context.l10n.allowed,
              allowed: true,
            ),
            _PermissionItem(
              name: context.l10n.biometrics,
              status: context.l10n.notAllowed,
              allowed: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(context.l10n.openSettings),
          ),
        ],
      ),
    );
  }

  static void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.clearAllDataConfirmTitle),
        content: Text(context.l10n.clearAllDataConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.allDataCleared)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.deleteAll),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  const _PermissionItem({
    required this.name,
    required this.status,
    required this.allowed,
  });

  final String name;
  final String status;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle : Icons.cancel,
            color: allowed ? AppColors.success : colorScheme.error,
            size: 20,
          ),
          context.sm.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  status,
                  style: context.textTheme.bodySmall?.copyWith(
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
}
