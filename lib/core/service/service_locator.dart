import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpensemate/core/localization/locale_manager.dart';
import 'package:xpensemate/core/network/network_client.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/core/network/network_info.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_local_storage.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:xpensemate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';
import 'package:xpensemate/features/auth/domain/usecases/cases_export.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:xpensemate/features/budget/data/datasources/budget_remote_data_source_impl.dart';
import 'package:xpensemate/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:xpensemate/features/budget/domain/repositories/budget_repository.dart';
import 'package:xpensemate/features/budget/domain/usecases/usecase_export.dart';
import 'package:xpensemate/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:xpensemate/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:xpensemate/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_budget_goals_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_product_weekly_analytics_usecase.dart';
import 'package:xpensemate/features/dashboard/domain/usecases/get_weekly_stats_usecase.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/expense/data/datasources/expense_remote_data_source.dart';
import 'package:xpensemate/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:xpensemate/features/expense/domain/repositories/expense_repository.dart';
import 'package:xpensemate/features/expense/domain/usecases/create_expense_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_budgets_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_expense_stats_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:xpensemate/features/expense/domain/usecases/update_expense_usecase.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/home/presentation/cubit/home_cubit.dart';
import 'package:xpensemate/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:xpensemate/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_image_usecase.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';

/// Global, lazy singleton
final sl = GetIt.instance;

/// ------------------------------------------------------------------s
/// 1️⃣  Register everything before `runApp`
/// ------------------------------------------------------------------
Future<void> initLocator() async {
  try {
    // Initialize services
    AppLogger.init(isDebug: kDebugMode);

    // Initialize SecureStorageService first
    await SecureStorageService.instance.initialize();

    // Then initialize LocaleManager
    await LocaleManager().initialize();

    // ---------- Core Services ----------

    // SharedPreferences (required for PermissionService)
    final sharedPrefs = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(sharedPrefs);

    // Permission Service
    sl.registerLazySingleton<PermissionService>(
      PermissionService.new,
    );

    // ---------- Network Connectivity ----------
    sl.registerLazySingleton<NetworkInfoService>(
      () => NetworkInfoServiceImpl(
        Connectivity(),
      ),
    );

    // ---------- Secure Storage Service ----------
    sl.registerLazySingleton<IStorageService>(
      () => SecureStorageService.instance,
    );

    // ---------- Secure Storage token ----------
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl()),
    );

    // ---------- Network Client ----------
    sl.registerLazySingleton<NetworkClient>(
      () => NetworkClientImp(
        tokenStorage: sl(),
      ),
    );

    // ---------- Data sources ----------
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl(), sl()),
    );
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<ExpenseRemoteDataSource>(
      () => ExpenseRemoteDataSourceImpl(sl()),
    );

    sl.registerLazySingleton<BudgetRemoteDataSource>(
      () => BudgetRemoteDataSourceImpl(sl()),
    );

    // ---------- Repositories ----------
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        sl(),
        sl(), // AuthLocalDataSource if  need for caching caching
      ),
    );
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl()),
    );

    sl.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(sl()),
    );

    sl.registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(sl()),
    );

    // ---------- Use-cases ----------
    sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
    sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
    sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
    sl.registerLazySingleton(() => SignOutUseCase(sl()));
    sl.registerLazySingleton(() => SignUpUseCase(sl()));
    sl.registerLazySingleton(() => SendVerificationEmailUseCase(sl()));
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
    sl.registerLazySingleton(() => UpdateProfileImageUseCase(sl()));
    // dashboard use cases
    sl.registerLazySingleton(() => GetWeeklyStatsUseCase(sl()));
    sl.registerLazySingleton(() => GetBudgetsUseCase(sl()));
    sl.registerLazySingleton(() => GetProductWeeklyAnalyticsUseCase(sl()));
    // expense use cases
    sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
    sl.registerLazySingleton(() => GetExpenseStatsUseCase(sl()));
    sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));
    sl.registerLazySingleton(() => UpdateExpenseUseCase(sl()));
    sl.registerLazySingleton(() => GetBudgetGoalsUseCase(sl()));
    sl.registerLazySingleton(() => CreateExpensesUseCase(sl()));
    // budget use cases
    sl.registerLazySingleton(() => CreateBudgetGoalUseCase(sl()));
    sl.registerLazySingleton(() => GetBudgetsGoalsUseCase(sl()));
    sl.registerLazySingleton(() => DeleteBudgetGoalUseCase(sl()));
    sl.registerLazySingleton(() => GetBudgetGoalByIdUseCase(sl()));
    sl.registerLazySingleton(() => GetBudgetGoalsByCategoryUseCase(sl()));
    sl.registerLazySingleton(() => GetBudgetGoalsByStatusUseCase(sl()));
    sl.registerLazySingleton(() => GetBudgetGoalsStatsUseCase(sl()));
    sl.registerLazySingleton(() => UpdateBudgetGoalUseCase(sl()));

    // ---------- Presentation Layer ----------
    sl.registerFactory(() => AuthCubit(sl()));
    sl.registerFactory(() => ProfileCubit(sl()));
    sl.registerFactory(
      () => DashboardCubit(sl(), sl(), sl()),
    );
    sl.registerFactory(() => ExpenseCubit(sl(), sl(), sl(), sl(), sl(), sl()));

    AppLogger.i('Service locator initialized successfully');
  } on Exception catch (e) {
    AppLogger.e('Error initializing services: $e');
    if (kDebugMode) {
      print('Error initializing services: $e');
    }
    rethrow;
  }
}

/// ------------------------------------------------------------------
/// 3️⃣  Cleanup (for testing or app reset)
/// ------------------------------------------------------------------
Future<void> resetServiceLocator() async {
  await sl.reset();
}

/// ------------------------------------------------------------------
/// 4️⃣  Extension for easy access
/// ------------------------------------------------------------------
extension ServiceLocatorExtension on GetIt {
  /// Quick access to PermissionService
  PermissionService get permissions => this<PermissionService>();

  /// Quick access to other commonly used services
  NetworkInfoService get networkInfo => this<NetworkInfoService>();
  IStorageService get storage => this<IStorageService>();
  SharedPreferences get sharedPrefs => this<SharedPreferences>();

  /// Quick access to Presentation Cubits
  AuthCubit get authCubit => this<AuthCubit>();
  ProfileCubit get profileCubit => this<ProfileCubit>();
  DashboardCubit get dashboardCubit => this<DashboardCubit>();
  HomeCubit get homeCubit => this<HomeCubit>();
  ExpenseCubit get expenseCubit => this<ExpenseCubit>();
}
