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
import 'package:xpensemate/core/service/storage_service.dart';
import 'package:xpensemate/core/theme/app_theme.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
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
      // Initialize Crashlytics
      await sl.crashlytics.init();
      // Initialize Hive Storage
      await sl<StorageService>().init();
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

      // Record fatal error to Crashlytics
      AppLogger.e('Fatal error in main zone', error, stack);
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
          BlocProvider<PaymentCubit>(
            create: (context) => sl.paymentCubit,
          ),
          // Other cubits/blocs
        ],
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            return BlocSelector<ProfileCubit, ProfileState, ThemeMode>(
              selector: (state) =>
                  state is ProfileLoaded ? state.themeMode : ThemeMode.system,
              builder: (context, themeMode) => GestureDetector(
                onTap: AppUtils.unFocus,
                child: MaterialApp.router(
                  title: 'ExpenseTracker',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  debugShowCheckedModeBanner: false,
                  routerConfig: AppRouter(
                    authCubit,
                    RouteGuards(authCubit, sl<StorageService>()),
                    sl.analytics,
                  ).router,
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
                        if (supportedLocale.languageCode ==
                            locale.languageCode) {
                          return supportedLocale;
                        }
                      }
                    }
                    // Fallback to first supported locale (English)
                    return supportedLocales.first;
                  },
                ),
              ),
            );
          },
        ),
      );
}
