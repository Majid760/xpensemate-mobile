import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';

/// A dialog widget for selecting the application theme mode.
///
/// This dialog displays all available theme modes (Light, Dark, System) and
/// allows the user to select their preferred theme. It follows Material Design 3
/// patterns and uses system theme colors and localization throughout.
class ThemeDialog extends StatelessWidget {
  const ThemeDialog({
    required this.currentTheme,
    super.key,
  });

  /// The currently selected theme mode
  final ThemeMode currentTheme;

  /// Shows the theme selection dialog
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  static Future<void> show({
    required BuildContext context,
    required ThemeMode currentTheme,
  }) =>
      showDialog<void>(
        context: context,
        builder: (context) => ThemeDialog(
          currentTheme: currentTheme,
        ),
      );

  String _getThemeEmoji(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '☀️';
      case ThemeMode.dark:
        return '🌙';
      case ThemeMode.system:
        return '⚙️';
    }
  }

  String _getThemeTitle(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  String _getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system settings';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = context.l10n;

    final themeModes = [
      ThemeMode.light,
      ThemeMode.dark,
      ThemeMode.system,
    ];

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
                      Icons.palette_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.themeMode,
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
                itemCount: themeModes.length,
                separatorBuilder: (context, index) => Divider(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final mode = themeModes[index];
                  final isSelected = mode == currentTheme;

                  return InkWell(
                    onTap: () {
                      context.read<ProfileCubit>().updateTheme(mode);
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
                              _getThemeEmoji(mode),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getThemeTitle(context, mode),
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _getThemeDescription(mode),
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
