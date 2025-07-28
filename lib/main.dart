import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:xpensemate/core/localization/locale_manager.dart';
import 'package:xpensemate/core/localization/supported_locales.dart';
import 'package:xpensemate/core/route/app_router.dart';
import 'package:xpensemate/core/route/utils/router_middleware_guard.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/app_theme.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

void main() async {
  // Initialize services locator
  await initLocator();
  runApp(const MyApp());
}

/// main app class
class MyApp extends StatelessWidget {
  /// constructor of main app class
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
     providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit()..checkAuthStatus(),
        ),
        // Other cubits/blocss
      ],
        child: MaterialApp.router(
          title: 'ExpenseTracker',
          // Apply themes
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // themeMode: ThemeMode.system, // Follows system setting
          // Localization configuration
          routerConfig:
              AppRouter(context.authCubit, RouteGuards(context.authCubit))
                  .router,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: SupportedLocales.supportedLocales,
          locale: LocaleManager().currentLocale,
          // Locale resolution
          localeResolutionCallback: (locale, supportedLocales) {
            // If the current device locale is supported, use it
            if (locale != null) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            // Fallback to first supported locale (English)
            return supportedLocales.first;
          },
        ),
      );
}

