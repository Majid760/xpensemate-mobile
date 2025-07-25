import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, AuthTokenModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserModel>> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  });

  Future<Either<Failure, UserModel>> signInWithGoogle();

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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);
  final NetworkClient _client;

  /// Sign in with email and password
  @override
  Future<Either<Failure, AuthTokenModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _client.post(
        NetworkConfigs.login,
        body: {'email': email, 'password': password},
        fromJson: AuthTokenModel.fromJson,
      );

  /// Sign in with Google
  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() => 
      _client.post(NetworkConfigs.apiKey, fromJson: UserModel.fromJson);

  /// Sign in with Apple
  @override
  Future<Either<Failure, UserModel>> signInWithApple() =>
      _client.post(NetworkConfigs.apiKey, fromJson: UserModel.fromJson);


  /// Register with email and password
  @override
  Future<Either<Failure, UserModel>> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) =>
      _client.post(
        NetworkConfigs.register,
        body: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
        fromJson: UserModel.fromJson,
      );

  

  /// Forgot password
  @override
  Future<Either<Failure, void>> forgotPassword(String email) =>
      _client.post(NetworkConfigs.forgotPassword, body: {'email': email});

  /// Reset password
  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      _client.post(
        '${NetworkConfigs.resetPassword}/$token',
        body: {'password': newPassword},
      );
  

  /// Verify email
  @override
  Future<Either<Failure, void>> verifyEmail(String token) =>
      _client.get('${NetworkConfigs.verifyEmail}/$token');


  /// Refresh token
  @override
  Future<Either<Failure, AuthTokenModel>> refreshToken(String refreshToken) =>
      _client
          .post(NetworkConfigs.refreshToken, body: {'refresh': refreshToken});
 

  /// Get current user
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() =>
      _client.get(NetworkConfigs.currentUser, fromJson: UserModel.fromJson);
  
  /// Logout
  @override
  Future<Either<Failure, void>> logout() => _client.post(NetworkConfigs.logout);
}
