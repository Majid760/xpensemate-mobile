import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/app_typography.dart';
import 'package:xpensemate/core/theme/button_styles.dart';
import 'package:xpensemate/core/theme/colors/dark_colors.dart';
import 'package:xpensemate/core/theme/colors/light_colors.dart';
import 'package:xpensemate/core/theme/input_styles.dart';
import 'package:xpensemate/core/theme/theme_constant.dart';


class AppTheme {
  // Prevent instantiation
  AppTheme._();
  // Light Theme
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: LightColors.colorScheme,
        textTheme: AppTypography.textTheme,
      
        // Component themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtonStyles.elevatedButton,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: AppButtonStyles.filledButton,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppButtonStyles.outlinedButton,
        ),
        textButtonTheme: TextButtonThemeData(
          style: AppButtonStyles.textButton,
        ),
        inputDecorationTheme: AppInputStyles.inputDecorationTheme,
      
        // App Bar
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: ThemeConstants.elevationLow,
          backgroundColor: LightColors.colorScheme.surface,
          foregroundColor: LightColors.colorScheme.onSurface,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        
        // Card
        // cardTheme: CardTheme(
        //   elevation: ThemeConstants.elevationLow,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        //   ),
        //   margin: const EdgeInsets.all(AppSpacing.sm),
        // ),
        
        // Divider
        dividerTheme: DividerThemeData(
          space: AppSpacing.sm,
          thickness: 1,
          color: LightColors.colorScheme.outlineVariant,
        ),
      );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: DarkColors.colorScheme,
        textTheme: AppTypography.textTheme,
        
        // Component themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtonStyles.elevatedButton,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: AppButtonStyles.filledButton,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppButtonStyles.outlinedButton,
        ),
        textButtonTheme: TextButtonThemeData(
          style: AppButtonStyles.textButton,
        ),
        inputDecorationTheme: AppInputStyles.inputDecorationTheme,
        
        // App Bar
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: ThemeConstants.elevationLow,
          backgroundColor: DarkColors.colorScheme.surface,
          foregroundColor: DarkColors.colorScheme.onSurface,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        
        // Card
        // cardTheme: CardTheme(
        //   elevation: ThemeConstants.elevationLow,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        //   ),
        //   margin: const EdgeInsets.all(AppSpacing.sm),
        // ),
        
        // Divider
        dividerTheme: DividerThemeData(
          space: AppSpacing.sm,
          thickness: 1,
          color: DarkColors.colorScheme.outlineVariant,
        ),
      );
}