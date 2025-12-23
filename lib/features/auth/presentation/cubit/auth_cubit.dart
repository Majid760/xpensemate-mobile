import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/route_constants.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/usecases/cases_export.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> with ChangeNotifier {
  AuthCubit() : super(const AuthState()) {
    // Don't initialize auth immediately, let it be initialized when needed
  }

  /// Initialize auth - should be called during app startup
  Future<void> initializeAuth() async {
    // Ensure AuthService is initialized first
    if (!sl.authService.isInitialized) {
      await sl.authService.initializeService();
    }

    final user = sl.authService.currentUser;
    if (user != null) {
      unawaited(sl.crashlytics.setUserIdentifier(user.id));
      unawaited(sl.crashlytics.setCustomKey('is_authenticated', true));
      unawaited(sl.crashlytics.log('User session restored: ${user.id}'));
    } else {
      unawaited(sl.crashlytics.setCustomKey('is_authenticated', false));
    }

    emit(
      state.copyWith(
        state: AuthStates.loaded,
        isAuthenticated: sl.authService.isAuthenticated,
        user: user,
      ),
    );
  }

  /// login with email
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    sl.crashlytics.log('User starting login process...');
    emit(state.copyWith(state: AuthStates.loading, errorMessage: ''));
    final loginUseCase = sl<SignInWithEmailUseCase>();
    final result = await loginUseCase.call(
      SignInWithEmailUseCaseParams(email: email, password: password),
    );
    result.fold(
      (failure) {
        unawaited(sl.crashlytics.log('Login failed: ${failure.message}'));
        emit(
          state.copyWith(
            state: AuthStates.error,
            errorMessage: failure.message,
            isAuthenticated: false,
          ),
        );
      },
      (user) {
        unawaited(sl.crashlytics.setUserIdentifier(user.id));
        unawaited(sl.crashlytics.setCustomKey('is_authenticated', true));
        unawaited(sl.crashlytics.log('Login successful for user: ${user.id}'));
        emit(
          state.copyWith(
            state: AuthStates.loaded,
            isAuthenticated: true,
            user: user,
          ),
        );
      },
    );
  }

  /// register with email
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    sl.crashlytics.log('User starting registration...');
    emit(state.copyWith(state: AuthStates.loading));
    final registerUseCase = sl<SignUpUseCase>();
    final result = await registerUseCase.call(
      SignUpUseCaseParams(fullName: fullName, email: email, password: password),
    );
    result.fold(
      (failure) {
        unawaited(
            sl.crashlytics.log('Registration failed: ${failure.message}'));
        emit(
          state.copyWith(
            state: AuthStates.error,
            isAuthenticated: false,
            errorMessage: failure.message,
          ),
        );
      },
      (user) {
        unawaited(sl.crashlytics.log('Registration successful'));
        emit(
          state.copyWith(
            state: AuthStates.loaded,
            isAuthenticated: false,
          ),
        );
      },
    );
  }

  /// forgot password
  Future<void> forgotPassword({required String email}) async {
    sl.crashlytics.log('User requested password reset');
    emit(state.copyWith(state: AuthStates.loading, errorMessage: ''));
    final forgotPasswordUseCase = sl<ForgotPasswordUseCase>();
    final result = await forgotPasswordUseCase.call(
      ForgotPasswordUseCaseParams(email: email),
    );
    result.fold(
      (failure) {
        unawaited(
            sl.crashlytics.log('Forgot password failed: ${failure.message}'));
        emit(
          state.copyWith(
            state: AuthStates.error,
            errorMessage: failure.message,
          ),
        );
      },
      (user) {
        unawaited(sl.crashlytics.log('Forgot password email sent'));
        emit(state.copyWith(state: AuthStates.loaded));
      },
    );
  }

  /// send verification email
  Future<void> sendVerificationEmail({required String email}) async {
    unawaited(sl.crashlytics.log('User requested verification email'));
    emit(state.copyWith(state: AuthStates.loading));
    final sendVerificationEmailUseCase = sl<SendVerificationEmailUseCase>();
    final result = await sendVerificationEmailUseCase.call(
      SendVerificationEmailUseCaseParams(email: email),
    );
    result.fold(
      (failure) {
        unawaited(sl.crashlytics
            .log('Verification email failed: ${failure.message}'));
        emit(
          state.copyWith(
            state: AuthStates.error,
            errorMessage: failure.message,
          ),
        );
      },
      (res) {
        unawaited(sl.crashlytics.log('Verification email sent'));
        emit(state.copyWith(state: AuthStates.loaded));
      },
    );
  }

  // isAuthenticated
  bool isAuthenticated() =>
      (state.user != null) && (state.isAuthenticated == true);

  // sign out
  Future<void> signOut({String? error}) async {
    sl.crashlytics.log('User signing out...');
    emit(state.copyWith(state: AuthStates.loading));
    final signOutUseCase = sl<SignOutUseCase>();
    final result = await signOutUseCase.call(const NoParams());
    result.fold(
      (failure) {
        unawaited(sl.crashlytics.log('Sign out failure: ${failure.message}'));
        emit(
          state.copyWith(
            state: AuthStates.error,
            errorMessage: failure.message,
            isAuthenticated: false,
          ),
        );
      },
      (user) {
        unawaited(sl.crashlytics.setUserIdentifier(''));
        unawaited(sl.crashlytics.setCustomKey('is_authenticated', false));
        unawaited(sl.crashlytics.log('Sign out successful, user cleared'));
        emit(
          state.copyWith(
            state: AuthStates.loaded,
            errorMessage: error,
            isAuthenticated: false,
            user: null,
          ),
        );
      },
    );
  }

  /// check auth status
  Future<void> checkAuthStatus() async {
    if (isAuthenticated()) {
      emit(state.copyWith(state: AuthStates.loaded));
    } else {
      emit(state.copyWith(state: AuthStates.error));
    }
  }
  // getter of user

  UserEntity? get user => state.user;
  void updateUser(UserEntity user) {
    try {
      emit(state.copyWith(user: user));
      sl.authService.updateUserInStorage(user);
    } on Exception catch (e, s) {
      unawaited(sl.crashlytics
          .recordError(e, s, reason: 'updateUserInStorage failed'));
    }
  }

  void setIsAuthenticated({required bool isAuthenticated}) =>
      emit(state.copyWith(isAuthenticated: isAuthenticated));
}

// add ssome nice extensions to get the controller in ui/widget
extension AuthCubitExtension on BuildContext {
  AuthCubit get authCubit => read<AuthCubit>();

  /// Navigate to login page
  void navigateToLogin() {
    goRouter.go(RouteConstants.login);
  }

  /// Get GoRouter instance
  GoRouter get goRouter => GoRouter.of(this);
}
