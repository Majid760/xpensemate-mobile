import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

abstract class AuthLocalDataSource {
  // Token Management
  Future<void> storeTokens(AuthTokenModel tokens);
  Future<AuthTokenModel?> getStoredTokens();
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> updateAccessToken(String newToken);
  Future<void> clearTokens();
  Future<bool> hasValidTokens();

  // User Data Management
  Future<void> storeUser(UserEntity user);
  Future<UserEntity?> getStoredUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._storageService);
  final IStorageService _storageService;

  // TOKEN MANAGEMENT
  @override
  Future<void> storeTokens(AuthTokenModel tokens) async {
    try {
      await _storageService.write(
        StorageKeys.accessToken,
        tokens.accessToken,
      );

      if (tokens.refreshToken != null) {
        await _storageService.write(
          StorageKeys.refreshToken,
          tokens.refreshToken!,
        );
        logI('refresh token saved locally successfully!');
      }

      // Store token expiration info
      final expirationTime = DateTime.now().add(Duration(seconds: tokens.expiresIn));
      await _storageService.write(
        StorageKeys.tokenExpiration,
        expirationTime.toIso8601String(),
      );

      // Store complete token object as JSON for backup
      final tokenJson = json.encode(tokens.toJson());
      await _storageService.write(StorageKeys.authTokens, tokenJson);
      logI('yes user tokens saved locally successfully!');
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _storageService.read(StorageKeys.accessToken);
      return token;
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _storageService.write(StorageKeys.accessToken, token);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _storageService.read(StorageKeys.refreshToken);
      return token;
    } on Exception catch (e) {
      logE('Exception getting refresh token: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storageService.write(StorageKeys.refreshToken, token);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<AuthTokenModel?> getStoredTokens() async {
    try {
      final tokenJson = await _storageService.read(StorageKeys.authTokens);
      if (tokenJson == null) return null;
      final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
      final tokens = AuthTokenModel.fromJson(tokenMap);
      return tokens;
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> updateAccessToken(String newToken) async {
    try {
      await _storageService.write(StorageKeys.accessToken, newToken);

      // Update token expiration (assuming 1 hour default)
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      await _storageService.write(
        'token_expiration',
        expirationTime.toIso8601String(),
      );
      return;
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storageService.delete(StorageKeys.accessToken),
        _storageService.delete(StorageKeys.refreshToken),
        _storageService.delete(StorageKeys.authTokens),
        _storageService.delete(StorageKeys.tokenExpiration),
      ]);
      logI('tokens cleared successfully!');
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> hasValidTokens() async {
    try {
      final accessToken = await _storageService.read(StorageKeys.accessToken);
      if (accessToken == null || accessToken.isEmpty) return false;

      // Check if token is expired
      final expirationString = await _storageService.read('token_expiration');
      if (expirationString != null) {
        final expirationTime = DateTime.parse(expirationString);
        if (DateTime.now().isAfter(expirationTime)) return false;
      }

      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  // ========== USER DATA MANAGEMENT ==========

  @override
  Future<void> storeUser(UserEntity user) async {
    try {
      // Store complete user object as JSON
      final userJson = json.encode(user is UserModel ? user.toJson() : user.toModel.toJson());
      await _storageService.write(StorageKeys.userData, userJson);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getStoredUser() async {
    try {
      final userJson = await _storageService.read(StorageKeys.userData);
      if (userJson == null || userJson.isEmpty) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap).toEntity();
      return user;
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> clearUser() async {
    try {
      await _storageService.delete(StorageKeys.userData);
      return const Right(null);
    } on Exception catch (e) {
      debugPrint('❌ error deleting user , error => $e');
      return Left(LocalDataFailure(message: 'Failed to clear user: $e'));
    }
  }
}

// Extension methods for easier token handling
extension AuthTokenModelExtensions on AuthTokenModel {
  /// Check if the access token is expired
  bool get isAccessTokenExpired {
    final now = DateTime.now();
    final expirationTime = DateTime.now().add(Duration(seconds: expiresIn));
    return now.isAfter(expirationTime);
  }

  /// Get time remaining until token expires
  Duration get timeUntilExpiration {
    final now = DateTime.now();
    final expirationTime = DateTime.now().add(Duration(seconds: expiresIn));
    return expirationTime.difference(now);
  }

  /// Check if token needs refresh (expires in less than 5 minutes)
  bool get needsRefresh => timeUntilExpiration.inMinutes < 5;
}
