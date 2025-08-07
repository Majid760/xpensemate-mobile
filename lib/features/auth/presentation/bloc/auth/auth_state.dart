import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.stackTrace,
  });

  /// Initial state
  const AuthState.initial() : this();

   /// Loading state
  const AuthState.loading() : this(status: AuthStatus.loading);

/// Authenticated state
  const AuthState.authenticated(UserEntity user)
      : this(
          status: AuthStatus.authenticated,
          user: user,
        );

          /// Unauthenticated state
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  /// Error state
  const AuthState.error(
    String message, [
    StackTrace? stackTrace,
  ]) : this(
          status: AuthStatus.error,
          errorMessage: message,
          stackTrace: stackTrace,
        );


  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final StackTrace? stackTrace;



  /// Copy with method for immutability
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    StackTrace? stackTrace,
  }) => AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      stackTrace: stackTrace ?? this.stackTrace,
    );

  /// Check if the user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Check if the state is in loading state
  bool get isLoading => status == AuthStatus.loading;

  /// Check if the state is in error state
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, user, errorMessage];

  @override
  String toString() => 'AuthState { status: $status, user: ${user?.email}, error: $errorMessage }';
}
