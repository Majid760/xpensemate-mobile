import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:xpensemate/core/localization/locale_manager.dart';
import 'package:xpensemate/core/network/network_client.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/core/network/network_info.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:xpensemate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';
import 'package:xpensemate/features/auth/domain/usecases/cases_export.dart';
/// Global, lazy singleton
final sl = GetIt.instance;

/// ------------------------------------------------------------------
/// 1️⃣  Register everything before `runApp`
/// ------------------------------------------------------------------
Future<void> initLocator() async {
  try {
    // Initialize services
    AppLogger.init(isDebug: kDebugMode);
    
    // Initialize SecureStorageService first
    await SecureStorageService.initialize();
    
    // Then initialize LocaleManager
    await LocaleManager().initialize();

    // ---------- Network Connectivity ----------
    sl.registerLazySingleton<NetworkInfoService>(
      () => NetworkInfoServiceImpl(
        Connectivity(),
      ),
    );
   

    // ---------- Network Client ----------
    sl.registerLazySingleton<NetworkClient>(
      () => NetworkClientImp(
        token: '',
        refreshToken: () async => null,
      ),
    );

    // ---------- Data sources ----------
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    );

    // ---------- Repositories ----------
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),// AuthLocalDataSource if you need caching
      ),
    );

    // ---------- Use-cases ----------
    sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
    sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
    sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
    sl.registerLazySingleton(() => SignOutUseCase(sl()));
    sl.registerLazySingleton(() => SignUpUseCase(sl()));
    sl.registerLazySingleton(() => SendVerificationEmailUseCase(sl()));
  } on Exception catch (e) {
    if (kDebugMode) {
      print('Error initializing services: $e');
    }
  }
}

/// ------------------------------------------------------------------
/// 2️⃣  Helpers (token retrieval)
/// ------------------------------------------------------------------
