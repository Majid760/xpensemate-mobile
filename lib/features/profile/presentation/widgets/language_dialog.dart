import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';

/// A dialog widget for selecting the application language.
///
/// This dialog displays all supported locales and allows the user to select
/// their preferred language. It follows Material Design 3 patterns and uses
/// system theme colors and localization throughout.
class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    required this.currentLocale,
    required this.onLanguageChanged,
    super.key,
  });

  /// The currently selected locale
  final Locale currentLocale;

  /// Callback invoked when a language is selected
  final ValueChanged<Locale> onLanguageChanged;

  /// Shows the language selection dialog
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  static Future<void> show({
    required BuildContext context,
    required Locale currentLocale,
    required ValueChanged<Locale> onLanguageChanged,
  }) =>
      showDialog<void>(
        context: context,
        builder: (context) => LanguageDialog(
          currentLocale: currentLocale,
          onLanguageChanged: onLanguageChanged,
        ),
      );

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ar':
        return '🇸🇦';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.language,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.selectLanguage,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                shrinkWrap: true,
                itemCount: SupportedLocales.supportedLocales.length,
                separatorBuilder: (context, index) => Divider(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final locale = SupportedLocales.supportedLocales[index];
                  final isSelected =
                      locale.languageCode == currentLocale.languageCode;

                  return InkWell(
                    onTap: () {
                      onLanguageChanged(locale);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getLanguageFlag(locale.languageCode),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  SupportedLocales.getDisplayName(locale),
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  locale.languageCode.toUpperCase(),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                              size: 24,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: colorScheme.outlineVariant,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
