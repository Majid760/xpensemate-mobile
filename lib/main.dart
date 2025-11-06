import 'dart:async';

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
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/firebase_options.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Initialize services locator/dependency injection
      await initLocator();

      // Initialize auth cubit after service locator is ready
      await sl<AuthCubit>().initializeAuth();

      runApp(const MyApp());
    },
    (error, stack) {
      // Improved error logging with more context and better formatting
      debugPrint('🔥 FATAL ERROR CAUGHT IN MAIN:');
      debugPrint('==============================');
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stack');
      debugPrint('==============================');

      // TODO: Implement proper error reporting to Crashlytics or other error tracking service
      // Example: FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}

/// main app class
class MyApp extends StatelessWidget {
  /// constructor of main app class
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => sl.authCubit,
            lazy: false,
          ),
          BlocProvider<ProfileCubit>(
            create: (context) => sl.profileCubit,
            lazy: false,
          ),
          BlocProvider<DashboardCubit>(
            create: (context) => sl.dashboardCubit,
            lazy: false,
          ),
          BlocProvider<ExpenseCubit>(
            create: (context) => sl.expenseCubit,
            lazy: false,
          ),
          BlocProvider<BudgetCubit>(
            create: (context) => sl.budgetCubit,
            lazy: false,
          ),
          BlocProvider<BudgetExpensesCubit>(
            create: (context) => sl.budgetExpensesCubit,
          ),
          // Other cubits/blocs
        ],
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            return GestureDetector(
              onTap: AppUtils.unFocus,
              child: MaterialApp.router(
                title: 'ExpenseTracker',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                debugShowCheckedModeBanner: false,
                // themeMode: ThemeMode.system, // Follows system setting
                // Localization configuration
                routerConfig:
                    AppRouter(authCubit, RouteGuards(authCubit)).router,
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
          },
        ),
      );
}
