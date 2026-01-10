import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_info.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/utils/network_mixin.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';
import 'package:xpensemate/features/auth/data/services/auth_service.dart';
import 'package:xpensemate/features/auth/domain/entities/auth_token.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl
    with NetworkCheckMixin<Failure>
    implements AuthRepository {
  AuthRepositoryImpl(
    this.remoteDataSource,
    this.networkInfo,
    this.authService,
  );
  final AuthRemoteDataSource remoteDataSource;
  @override
  final NetworkInfoService networkInfo;
  final AuthService authService;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    final localUser = await authService.fetchUserFromStorage();
    if (networkInfo.isConnect || localUser == null) {
      final remoteResult = await remoteDataSource.getCurrentUser();
      return remoteResult.fold(
        (failure) {
          if (localUser != null) return Right(localUser);
          return Left(failure);
        },
        (userModel) async {
          final entity = userModel.toEntity();
          await authService.saveUserToStorage(entity);
          return Right(entity);
        },
      );
    }

    return Right(localUser);
  }

  /// Sign in with email and password
  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return withNetworkCheck(() async {
        final result = await remoteDataSource.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return await result.fold(
          (failure) async => Left(failure),
          (data) async {
            final (UserModel userModel, AuthTokenModel tokenModel) = data;
            final userEntity = userModel.toEntity();
            await Future.wait([
              authService.saveTokenToStorage(tokenModel),
              authService.saveUserToStorage(userEntity),
            ]);
            return Right(userEntity);
          },
        );
      });
    } on Exception catch (e) {
      logE("Exception occurs at signInWithEmailAndPassword $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  /// Register with email and password
  @override
  Future<Either<Failure, void>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final result = await remoteDataSource.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: fullName.split(' ').first,
        lastName: fullName.split(' ').last,
      );
      return result.fold(
        left,
        (_) => right(null),
      );
    } on Exception catch (e) {
      logE("Exception occurs at registerWithEmailAndPassword $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  /// Sign in with Google
  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle(
      {required String credential}) async {
    try {
      return withNetworkCheck(() async {
        final result =
            await remoteDataSource.signInWithGoogle(credential: credential);
        return await result.fold(
          (failure) async => Left(failure),
          (data) async {
            final (UserModel userModel, AuthTokenModel tokenModel) = data;
            final userEntity = userModel.toEntity();

            await authService.saveTokenToStorage(tokenModel);
            await authService.saveUserToStorage(userEntity);

            return Right(userEntity);
          },
        );
      });
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  /// Sign in with Apple
  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      return withNetworkCheck(() async {
        final result = await remoteDataSource.signInWithApple();
        return await result.fold(
          (failure) async => Left(failure),
          (data) async {
            final (UserModel userModel, AuthTokenModel tokenModel) = data;
            final userEntity = userModel.toEntity();

            await authService.saveTokenToStorage(tokenModel);
            await authService.saveUserToStorage(userEntity);

            return Right(userEntity);
          },
        );
      });
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  /// Sign out
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Clear local data first
      await authService.clearUserData();

      final result = await remoteDataSource.logout();
      return result.fold(
        Left.new,
        (_) => const Right(null),
      );
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  /// Refresh token
  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      return withNetworkCheck(() async {
        final result = await remoteDataSource.refreshToken(refreshToken);
        return await result.fold(
          (failure) async => Left(failure),
          (tokenModel) async {
            await authService.saveTokenToStorage(tokenModel);
            return Right(tokenModel.toEntity());
          },
        );
      });
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  /// Send password reset email
  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      return withNetworkCheck(() async {
        final result = await remoteDataSource.forgotPassword(email);
        return result.fold(
          left,
          (_) => right(null),
        );
      });
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  @override
  Future<Either<Failure, dynamic>> sendVerificationEmail(String email) async {
    try {
      return withNetworkCheck(() async {
        final result = await remoteDataSource.sendVerificationEmail(email);
        return result.fold(left, right);
      });
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
      return left(e.toFailure() as AuthenticationFailure);
    }
  }
}
