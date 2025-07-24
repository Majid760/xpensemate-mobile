import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/auth/domain/entities/auth_token.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  // Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  // Get current user
  Future<Either<Failure, User>> getCurrentUser();

  // Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Register with email and password
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  });

  // Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle();

  // Sign in with Apple
  Future<Either<Failure, User>> signInWithApple();

  // Sign out
  Future<Either<Failure, void>> signOut();

  // Refresh token
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);

  // Forgot password
  Future<Either<Failure, void>> forgotPassword(String email);

  // Verify email
  Future<Either<Failure, void>> verifyEmail(String code);

  // Get auth tokens
  Future<AuthToken?> getAuthToken();
}
