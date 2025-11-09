import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_local_storage.dart';

import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';
import 'package:xpensemate/features/auth/data/services/auth_service.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, UserModel>> signInWithGoogle({
    required String credential,
  });

  Future<Either<Failure, UserModel>> signInWithApple();

  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<Either<Failure, void>> verifyEmail(String token);
  Future<Either<Failure, AuthTokenModel>> refreshToken(String refreshToken);
  Future<Either<Failure, UserModel>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> sendVerificationEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(
    this._client,
    this._authService,
  );
  final NetworkClient _client;
  final AuthService _authService;

  /// Sign in with email and password
  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        NetworkConfigs.login,
        data: {'email': email, 'password': password},
        fromJson: (Map<String, dynamic> json) => json, // Return raw JSON
      );
      return await response.fold(
        (failure) async {
          logE('error is comingg while logigng ${failure.error}');
          return Left(failure);
        },
        (json) async {
          final (user, token) = await compute(_parseUserFromJson, json);
          unawaited(_authService.saveTokenToStorage(token));
          unawaited(_authService.saveUserToStorage(user));
          return Right(user);
        },
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Sign in with Google
  @override
  Future<Either<Failure, UserModel>> signInWithGoogle({
    required String credential,
  }) =>
      _client.post(
        NetworkConfigs.loginWithGoogle,
        data: {
          "credential": credential,
        },
        fromJson: UserModel.fromJson,
      );

  /// Sign in with Apple
  @override
  Future<Either<Failure, UserModel>> signInWithApple() =>
      _client.post(NetworkConfigs.apiKey, fromJson: UserModel.fromJson);

  /// Register with email and password
  @override
  Future<Either<Failure, void>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) =>
      _client.post(
        NetworkConfigs.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

  /// Forgot password
  @override
  Future<Either<Failure, void>> forgotPassword(String email) =>
      _client.post(NetworkConfigs.forgotPassword, data: {'email': email});

  /// Reset password
  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      _client.post(
        '${NetworkConfigs.resetPassword}/$token',
        data: {'password': newPassword},
      );

  /// Verify email
  @override
  Future<Either<Failure, void>> verifyEmail(String token) =>
      _client.get('${NetworkConfigs.verifyEmail}/$token');

  /// Refresh token
  @override
  Future<Either<Failure, AuthTokenModel>> refreshToken(String refreshToken) =>
      _client.post(
        NetworkConfigs.refreshToken,
        data: {'refresh': refreshToken},
        fromJson: AuthTokenModel.fromJson,
      );

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      // Start both operations concurrently
      final remoteUserFuture = _client.get(
        NetworkConfigs.currentUser,
        fromJson: UserModel.fromJson,
      ); // Returns Either<Failure, UserModel?>

      // Convert both to the same type for Future.any
      final remoteConverted = remoteUserFuture.then(
        (either) => either.fold<Either<Failure, UserModel>>(
          Left.new,
          Right.new,
        ),
      );

      final userEntity = await _authService.fetchUserFromStorage();
      final localConverted = userEntity == null
          ? const Right<Failure, UserModel?>(null)
              as Future<Either<Failure, UserModel>>
          : Future.value(
              Right<Failure, UserModel>(
                UserModel.fromEntity(userEntity),
              ),
            );

      final firstResult = await Future.any<Either<Failure, UserModel>>(
        [remoteConverted, localConverted],
      );
      // If first result is successful, return it
      final isFirstResultRight = firstResult.fold(
        (_) => false,
        (_) => true,
      );
      if (isFirstResultRight) {
        return firstResult;
      }

      // If first result failed, wait for both and return the successful one
      final results = await Future.wait<Either<Failure, UserModel>>([
        remoteConverted.catchError(
          (_) => const Left<Failure, UserModel>(
            ServerFailure(message: 'Remote fetching failed'),
          ),
        ),
        localConverted.catchError(
          (_) => const Left<Failure, UserModel>(
            LocalDataFailure(message: 'Local data fetching failed'),
          ),
        ),
      ]);

      // Find the first successful result
      for (final result in results) {
        final isResultRight = result.fold(
          (_) => false,
          (_) => true,
        );
        if (isResultRight) {
          return result;
        }
      }
      return const Left(
        ServerFailure(message: 'Failed to get user from both sources'),
      );
    } on Exception catch (e) {
      return Left(
        ServerFailure(message: 'Error getting current user: $e}'),
      );
    }
  }

  /// Send verification email
  @override
  Future<Either<Failure, dynamic>> sendVerificationEmail(String email) =>
      _client
          .post(NetworkConfigs.sendVerificationEmail, data: {'email': email});

  /// Logout
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final results = await Future.wait([
        _authService.clearUserData(),
        Future(() async {
          await _authService.clearUserData();
          return const Right<Failure, void>(null);
        }),
      ]);
      return results.first as Either<Failure, void>;
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  // return _client.post(NetworkConfigs.logout);
}

// Compute functions for better performance
(UserModel, AuthTokenModel) _parseUserFromJson(Map<String, dynamic> json) =>
    (UserModel.fromJson(json), AuthTokenModel.fromJson(json));
