import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/core/service/secure_storage_service.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';

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
  Future<Either<Failure, void>> sendVerificationEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client, this._tokenStorage);
  final NetworkClient _client;
  final IStorageService _tokenStorage;


  /// Sign in with email and password
  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<dynamic>(
        NetworkConfigs.login,
        body: {'email': email, 'password': password},
      );
    
      return response.fold(
        Left.new,
        (rawResponse) async {
          if (rawResponse is Map<String, dynamic>) {
            final user = UserModel.fromJson(rawResponse);
            
            // Store tokens using generic methods
            if (rawResponse['token'] != null) {
              await _tokenStorage.save(StorageKeys.accessTokenKey, rawResponse['token'] as String);
              
              if (rawResponse['refreshToken'] != null) {
                await _tokenStorage.save(StorageKeys.refreshTokenKey, rawResponse['refreshToken'] as String);
              }
            }
            
            return Right(user);
          }
          
          return const Left(ServerFailure(message: 'Invalid response format'));
        },
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
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
  Future<Either<Failure, void>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName, 
  }) =>
      _client.post(
        NetworkConfigs.register,
        body: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
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
      _client.post(
        NetworkConfigs.refreshToken, 
        body: {'refresh': refreshToken},
        fromJson: AuthTokenModel.fromJson,
      );
 

  /// Get current user
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() =>
      _client.get(NetworkConfigs.currentUser, fromJson: UserModel.fromJson);

  /// Send verification email
  @override
  Future<Either<Failure, dynamic>> sendVerificationEmail(String email) =>
      _client.post(NetworkConfigs.sendVerificationEmail, body: {'email': email});

  
  /// Logout
  @override
  Future<Either<Failure, void>> logout() => _client.post(NetworkConfigs.logout);
}
