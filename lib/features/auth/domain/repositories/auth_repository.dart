import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/auth/domain/entities/auth_token.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  // Check if user is authenticated
Future<Either<Failure, bool>> isAuthenticated();
  
  // Get current user
 Future<Either<Failure, UserEntity>> getCurrentUser();
  
  // Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  // Register with email and password
  Future<Either<Failure, void>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });
  
  // Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  
  // Sign in with Apple
  Future<Either<Failure, UserEntity>> signInWithApple();
  
  // Sign out
  Future<Either<Failure, void>> signOut();
  
  // Refresh token
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);
  
  // Forgot password
  Future<Either<Failure, void>> forgotPassword(String email);
  

  // Send verification email
  Future<Either<Failure, dynamic>> sendVerificationEmail(String email);
  
  
  // Get auth tokens
  Future<AuthToken?> getAuthToken();
}


