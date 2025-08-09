import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';


abstract class AuthLocalDataSource {
  // Token Management
  Future<Either<Failure, void>> storeTokens(AuthTokenModel tokens);
  Future<Either<Failure, AuthTokenModel?>> getStoredTokens();
  Future<Either<Failure, String?>> getAccessToken();
  Future<Either<Failure, String?>> getRefreshToken();
  Future<Either<Failure, void>> updateAccessToken(String newToken);
  Future<Either<Failure, void>> clearTokens();
  Future<Either<Failure, bool>> hasValidTokens();
  
  // User Data Management
  Future<Either<Failure, void>> storeUser(UserModel user);
  Future<Either<Failure, UserModel?>> getStoredUser();
  Future<Either<Failure, void>> updateUser(UserModel user);
  Future<Either<Failure, void>> clearUser();
  

}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  
  const AuthLocalDataSourceImpl(this._storageService);
  final IStorageService _storageService;

  // TOKEN MANAGEMENT
  
  @override
  Future<Either<Failure, void>> storeTokens(AuthTokenModel tokens) async {
    try {
      // Store individual tokens
      await _storageService.save(StorageKeys.accessTokenKey, tokens.accessToken);
      
      if (tokens.refreshToken != null) {
        await _storageService.save(StorageKeys.refreshTokenKey, tokens.refreshToken!);
      }
      
      // Store token expiration info
      final expirationTime = DateTime.now().add(Duration(seconds: tokens.expiresIn));
      await _storageService.save('token_expiration', expirationTime.toIso8601String());
      
      // Store complete token object as JSON for backup
      final tokenJson = json.encode(tokens.toJson());
      await _storageService.save('auth_tokens', tokenJson);
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to store tokens: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthTokenModel?>> getStoredTokens() async {
    try {
      final tokenJson = await _storageService.get('auth_tokens');
      if (tokenJson == null || tokenJson.isEmpty) {
        return const Right(null);
      }
      
      final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
      final tokens = AuthTokenModel.fromJson(tokenMap);
      
      return Right(tokens);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to get stored tokens: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getAccessToken() async {
    try {
      final token = await _storageService.get(StorageKeys.accessTokenKey);
      return Right(token);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to get access token: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getRefreshToken() async {
    try {
      final token = await _storageService.get(StorageKeys.refreshTokenKey);
      return Right(token);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to get refresh token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAccessToken(String newToken) async {
    try {
      await _storageService.save(StorageKeys.accessTokenKey, newToken);
      
      // Update token expiration (assuming 1 hour default)
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      await _storageService.save('token_expiration', expirationTime.toIso8601String());
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to update access token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      await Future.wait([
        _storageService.remove(StorageKeys.accessTokenKey),
        _storageService.remove(StorageKeys.refreshTokenKey),
        _storageService.remove('auth_tokens'),
        _storageService.remove('token_expiration'),
      ]);
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to clear tokens: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasValidTokens() async {
    try {
      final accessToken = await _storageService.get(StorageKeys.accessTokenKey);
      if (accessToken == null || accessToken.isEmpty) {
        return const Right(false);
      }
      
      // Check if token is expired
      final expirationString = await _storageService.get('token_expiration');
      if (expirationString != null) {
        final expirationTime = DateTime.parse(expirationString);
        if (DateTime.now().isAfter(expirationTime)) {
          return const Right(false); // Token is expired
        }
      }
      
      return const Right(true);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to check token validity: $e'));
    }
  }

  // ========== USER DATA MANAGEMENT ==========

  @override
  Future<Either<Failure, void>> storeUser(UserModel user) async {
    try {
      // Store complete user object as JSON
      final userJson = json.encode(user.toJson());
      await _storageService.save(StorageKeys.userData, userJson);
      
      // Store individual user properties for quick access
      await _storageService.save(StorageKeys.userId, user.id);
      await _storageService.save(StorageKeys.userEmail, user.email);
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to store user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getStoredUser() async {
    try {
      final userJson = await _storageService.get(StorageKeys.userData);
      if (userJson == null || userJson.isEmpty) {
        return const Right(null);
      }
      
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);
      
      return Right(user);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to get stored user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserModel user) async {
    try {
      // Update complete user object
      await storeUser(user);
      return const Right(null);
    } on Exception catch (e) {
      return Left(LocalDataFailure(message: 'Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearUser() async {
    try {
      await Future.wait([
        _storageService.remove(StorageKeys.userData),
        // clear tokens 
        clearTokens(),
      ]);
      
      return const Right(null);
    } on Exception catch (e) {
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


