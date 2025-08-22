import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_info.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/utils/network_mixin.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_local_storage.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:xpensemate/features/auth/domain/entities/auth_token.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl
    with NetworkCheckMixin<Failure>
    implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final AuthRemoteDataSource remoteDataSource;
  @override
  final NetworkInfoService networkInfo;

  /// Get current user
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async =>
      withNetworkCheck(() async {
        final result = await remoteDataSource.getCurrentUser();
        return result.fold(
          left,
          (user) {
            user.toEntity();
            return right(user.toEntity());
          },
        );
      });

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
        return result.fold(
          left,
          (userModel) => right(userModel.toEntity()),
        );
      });
    } on Exception catch (e) {
      logE("thissi excepiton occurs $e");
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
      return left(e.toFailure() as AuthenticationFailure);
    }
  }

  /// Sign in with Google
  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      return withNetworkCheck(() async {
        final result = await remoteDataSource.signInWithGoogle();
        return result.fold(
          left,
          (user) => right(user.toEntity()),
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
        return result.fold(
          left,
          (user) => right(user.toEntity()),
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
      final result = await remoteDataSource.logout();
      return result.fold(
        left,
        (_) => right(null),
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
        return result.fold(
          left,
          (token) => right(token.toEntity()),
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
