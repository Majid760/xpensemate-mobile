import 'package:firebase_core/firebase_core.dart';
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
import 'package:xpensemate/firebase_options.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

void main() async {

   WidgetsFlutterBinding.ensureInitialized();  
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
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
          create: (context) => sl<AuthCubit>()..checkAuthStatus(),
          lazy: false,
        ),
        // Other cubits/blocs
      ],
      child: Builder(
        builder: (context) {
          final authCubit = context.read<AuthCubit>();
          return MaterialApp.router(
            title: 'ExpenseTracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            // themeMode: ThemeMode.system, // Follows system setting
            // Localization configuration
            routerConfig: AppRouter(authCubit, RouteGuards(authCubit)).router,
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
          );
        },
      ),
    );
}
