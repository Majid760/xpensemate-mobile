import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_local_storage.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

/// Auth service that manages authentication state and provides
/// centralized access to the current user
class AuthService {
  AuthService({
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource {
    _initialize();
  }

  final AuthLocalDataSource _localDataSource;
  final _userStreamController = StreamController<UserEntity?>.broadcast();

  Stream<UserEntity?> get userStream => _userStreamController.stream;

  static UserEntity? _currentUser;
  static bool _isAuthenticated = false;
  static bool _isInitialized = false;
  static String accessToken = '';
  static String refreshToken = '';

  // Getters
  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized; // Make this public
  String get token => accessToken;
  String get userRefreshToken => refreshToken;

  /// Initialize the service - load user from storage
  Future<void> _initialize() async {
    logI('AuthService: Initializing...');
    await initializeService();
    _isInitialized = true;
  }

  Future<void> initializeService() async {
    await Future.wait([
      fetchTokenFromStorage(),
      fetchUserFromStorage(),
    ]);
  }

  /// Load user from local storage
  Future<UserEntity?> fetchUserFromStorage() async {
    try {
      final userEntity = await _localDataSource.getStoredUser();
      if (userEntity == null || userEntity.isEmpty) {
        _currentUser = null;
        _isAuthenticated = false;
        _userStreamController.add(null);
        return null;
      } else {
        _currentUser = userEntity;
        _isAuthenticated = true;
        _userStreamController.add(userEntity);
        return userEntity;
      }
    } on Exception catch (e) {
      logE('AuthService: Error loading user from storage: $e');
      rethrow;
    }
  }

  /// save the user to storage
  Future<void> saveUserToStorage(UserEntity userEntity) async {
    try {
      await _localDataSource.storeUser(userEntity);
      _currentUser = userEntity;
      _isAuthenticated = true;
      _userStreamController.add(userEntity);
    } on Exception catch (e) {
      logE('AuthService: Error saving user to storage: $e');
      rethrow;
    }
  }

  // update the user in storage
  Future<void> updateUserInStorage(UserEntity userEntity) async {
    try {
      await saveUserToStorage(userEntity);
      _currentUser = userEntity;
    } on Exception catch (e) {
      logE('AuthService: Error updating user in storage: $e');
      rethrow;
    }
  }

  /// Clear all user data
  Future<void> clearUserData() async {
    try {
      await Future.wait([
        _localDataSource.clearUser(),
        clearAllTokens(),
      ]);
      _currentUser = null;
      _isAuthenticated = false;
      _userStreamController.add(null);
      logI('AuthService: User data cleared');
    } on Exception catch (e) {
      logE('AuthService: Error clearing user data: $e');
      rethrow;
    }
  }

  //// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Token >>>>>>>>>>>>>>>>>>>>

  /// // save the user token to storage
  Future<void> saveTokenToStorage(AuthTokenModel token) async {
    try {
      await _localDataSource.storeTokens(token);
      accessToken = token.accessToken;
      refreshToken = token.refreshToken ?? '';
    } on Exception catch (e) {
      logE('AuthService: Error saving user token to storage: $e');
      rethrow;
    }
  }

  // get the user tokens from storage
  Future<void> fetchTokenFromStorage() async {
    try {
      await Future.wait([
        getAccessToken(),
        getRefreshToken(),
      ]);
      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        if (kDebugMode) {
          logI('AuthService: User tokens fetched from storage');
        }
      }
    } on Exception catch (e) {
      logE('AuthService: Error getting user tokens from storage: $e');
      rethrow;
    }
  }

  // get access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _localDataSource.getAccessToken();
      if (token != null) {
        accessToken = token;
      }
      if (accessToken.isNotEmpty) {
        print("access token wowowoow ==> ${accessToken.substring(0, 10)}");
      }
      return token;
    } on Exception catch (e) {
      logE('AuthService: Error getting user Access token from storage: $e');
      rethrow;
    }
  }

  // save the access token
  Future<void> saveAccessToken(String token) async {
    try {
      await _localDataSource.saveAccessToken(token);
      accessToken = token;
    } on Exception catch (e) {
      logE('AuthService: Error saving user Access token to storage: $e');
      rethrow;
    }
  }

  // get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _localDataSource.getRefreshToken();
      if (token != null) {
        refreshToken = token;
      }
      if (refreshToken.isNotEmpty) {
        logI("refresh token wowowoow ==> ${refreshToken.substring(0, 10)}");
      }
      return token;
    } on Exception catch (e) {
      logE('AuthService: Error getting user Refresh Token from storage: $e');
      rethrow;
    }
  }

  // save the refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _localDataSource.saveRefreshToken(token);
      accessToken = token;
    } on Exception catch (e) {
      logE('AuthService: Error saving user refreshToken token to storage: $e');
      rethrow;
    }
  }

  // remove the token from local storage
  Future<void> clearAllTokens() async {
    try {
      await _localDataSource.clearTokens();
      refreshToken = '';
      accessToken = '';
      logI('Clearing all tokens');
    } on Exception catch (e) {
      logE('Error clearing all tokens: $e');
      rethrow;
    }
  }

  /// Check if user has valid session
  bool hasValidSession() => _isAuthenticated && _currentUser != null;

  /// Get user by id (if needed for specific use cases)
  String? get userId => _currentUser?.id;

  /// Get user email
  String? get userEmail => _currentUser?.email;
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
