import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';

/// A dialog widget for selecting the application currency.
///
/// This dialog displays all available currencies and allows the user to select
/// their preferred currency. It follows Material Design 3 patterns and uses
/// system theme colors and localization throughout.
class CurrencyDialog extends StatelessWidget {
  const CurrencyDialog({
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
    super.key,
  });

  /// The currently selected currency code
  final String selectedCurrency;

  /// List of available currencies with code, name, and symbol
  final List<Map<String, String>> currencies;

  /// Callback invoked when a currency is selected
  final ValueChanged<String> onCurrencyChanged;

  /// Shows the currency selection dialog
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  static Future<void> show({
    required BuildContext context,
    required String selectedCurrency,
    required List<Map<String, String>> currencies,
    required ValueChanged<String> onCurrencyChanged,
  }) =>
      showDialog<void>(
        context: context,
        builder: (context) => CurrencyDialog(
          selectedCurrency: selectedCurrency,
          currencies: currencies,
          onCurrencyChanged: onCurrencyChanged,
        ),
      );

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
                      Icons.attach_money,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.selectCurrency,
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
                itemCount: currencies.length,
                separatorBuilder: (context, index) => Divider(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = currency['code'] == selectedCurrency;

                  return InkWell(
                    onTap: () {
                      onCurrencyChanged(currency['code']!);
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
                              currency['symbol']!,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currency['name']!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  currency['code']!,
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
