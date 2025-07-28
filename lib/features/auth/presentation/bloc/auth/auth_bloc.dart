// import 'dart:async';

// import 'package:bloc/bloc.dart';
// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
// import 'package:xpensemate/core/error/failures.dart';
// import 'package:xpensemate/core/usecase/usecase.dart';
// import 'package:xpensemate/features/auth/domain/entities/user.dart';
// import 'package:xpensemate/features/auth/domain/usecases/verify_email_usecase.dart';
// import 'package:xpensemate/features/auth/presentation/bloc/auth/auth_event.dart';
// import 'package:xpensemate/features/auth/presentation/bloc/auth/auth_state.dart';

// class AuthBloc extends Cubit<AuthState> {
//   final GetCurrentUser getCurrentUser;
//   final LoginWithEmail loginWithEmail;
//   final RegisterWithEmail registerWithEmail;
//   final Logout logout;
//   final RequestPasswordReset requestPasswordReset;
//   final VerifyEmail verifyEmail;

//   AuthBloc({
//     required this.getCurrentUser,
//     required this.loginWithEmail,
//     required this.registerWithEmail,
//     required this.logout,
//     required this.requestPasswordReset,
//     required this.verifyEmail,
//   }) : super(const AuthState.initial()) {
//     on<AuthCheckRequested>(_onAuthCheckRequested);
//     on<LoginWithEmailRequested>(_onLoginWithEmailRequested);
//     on<RegisterWithEmailRequested>(_onRegisterWithEmailRequested);
//     on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
//     on<LoginWithAppleRequested>(_onLoginWithAppleRequested);
//     on<ForgotPasswordRequested>(_onForgotPasswordRequested);
//     on<LogoutRequested>(_onLogoutRequested);
//     on<EmailVerificationRequested>(_onEmailVerificationRequested);
//   }

//   /// Event handler for checking authentication status
//   Future<void> _onAuthCheckRequested(
//     AuthCheckRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
    
//     final result = await getCurrentUser(NoParams());
    
//     result.fold(
//       (failure) => emit(const AuthState.unauthenticated()),
//       (user) => emit(AuthState.authenticated(user)),
//     );
//   }

//   /// Event handler for email/password login
//   Future<void> _onLoginWithEmailRequested(
//     LoginWithEmailRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
    
//     final result = await loginWithEmail(
//       LoginWithEmailParams(
//         email: event.email,
//         password: event.password,
//       ),
//     );
    
//     _handleAuthResult(result, emit);
//   }

//   /// Event handler for email/password registration
//   Future<void> _onRegisterWithEmailRequested(
//     RegisterWithEmailRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
    
//     final result = await registerWithEmail(
//       RegisterWithEmailParams(
//         email: event.email,
//         password: event.password,
//         name: event.name,
//       ),
//     );
    
//     _handleAuthResult(result, emit);
//   }

//   /// Event handler for Google login
//   Future<void> _onLoginWithGoogleRequested(
//     LoginWithGoogleRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
//     // TODO: Implement Google Sign-In
//     emit(const AuthState.error('Google Sign-In not implemented'));
//   }

//   /// Event handler for Apple login
//   Future<void> _onLoginWithAppleRequested(
//     LoginWithAppleRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
//     // TODO: Implement Apple Sign-In
//     emit(const AuthState.error('Apple Sign-In not implemented'));
//   }

//   /// Event handler for password reset
//   Future<void> _onForgotPasswordRequested(
//     ForgotPasswordRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
    
//     final result = await requestPasswordReset(
//       RequestPasswordResetParams(email: event.email),
//     );
    
//     result.fold(
//       (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
//       (_) => emit(const AuthState.unauthenticated()),
//     );
//   }

//   /// Event handler for logout
//   Future<void> _onLogoutRequested(
//     LogoutRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
    
//     final result = await logout(NoParams());
    
//     result.fold(
//       (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
//       (_) => emit(const AuthState.unauthenticated()),
//     );
//   }

//   /// Event handler for email verification
//   Future<void> _onEmailVerificationRequested(
//     EmailVerificationRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthState.loading());
    
//     final result = await verifyEmail(
//       VerifyEmailParams(code: event.code),
//     );
    
//     result.fold(
//       (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
//       (_) => emit(const AuthState.unauthenticated()),
//     );
//   }

//   /// Helper method to handle authentication results
//   void _handleAuthResult(
//     Either<Failure, User> result,
//     Emitter<AuthState> emit,
//   ) {
//     result.fold(
//       (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
//       (user) => emit(AuthState.authenticated(user)),
//     );
//   }

//   /// Maps a Failure to a user-friendly error message
//   String _mapFailureToMessage(Failure failure) {
//     if (failure is ServerFailure) {
//       return failure.message;
//     } else if (failure is NetworkFailure) {
//       return 'No internet connection. Please check your connection and try again.';
//     } else if (failure is AuthenticationFailure) {
//       return 'Authentication failed. Please check your credentials and try again.';
//     } else if (failure is ValidationFailure) {
//       return 'Validation failed. Please check your input and try again.';
//     } else {
//       return 'An unexpected error occurred. Please try again.';
//     }
//   }

//   /// Disposes of resources when the bloc is closed
//   @override
//   Future<void> close() {
//     // Close any resources here if needed
//     return super.close();
//   }
// }
