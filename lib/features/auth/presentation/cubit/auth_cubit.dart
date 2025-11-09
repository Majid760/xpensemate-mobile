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
    
    emit(
      state.copyWith(
        state: AuthStates.loaded,
        isAuthenticated: sl.authService.isAuthenticated,
        user: sl.authService.currentUser,
      ),
    );
  }

  /// login with email
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(state: AuthStates.loading, errorMessage: ''));
    final loginUseCase = sl<SignInWithEmailUseCase>();
    final result = await loginUseCase.call(SignInWithEmailUseCaseParams(email: email, password: password));
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: AuthStates.error,
          errorMessage: failure.message,
          isAuthenticated: false,
        ),
      ),
      (user) => emit(
        state.copyWith(
          state: AuthStates.loaded,
          isAuthenticated: true,
          user: user,
        ),
      ),
    );
  }

  /// register with email
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(state: AuthStates.loading));
    final registerUseCase = sl<SignUpUseCase>();
    final result = await registerUseCase.call(
      SignUpUseCaseParams(fullName: fullName, email: email, password: password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: AuthStates.error,
          isAuthenticated: false,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          state: AuthStates.loaded,
          isAuthenticated: false,
        ),
      ),
    );
  }

  /// forgot password
  Future<void> forgotPassword({required String email}) async {
    emit(state.copyWith(state: AuthStates.loading, errorMessage: ''));
    final forgotPasswordUseCase = sl<ForgotPasswordUseCase>();
    final result = await forgotPasswordUseCase.call(ForgotPasswordUseCaseParams(email: email));
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: AuthStates.error,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(state: AuthStates.loaded)),
    );
  }

  /// send verification email
  Future<void> sendVerificationEmail({required String email}) async {
    emit(state.copyWith(state: AuthStates.loading));
    final sendVerificationEmailUseCase = sl<SendVerificationEmailUseCase>();
    final result = await sendVerificationEmailUseCase.call(SendVerificationEmailUseCaseParams(email: email));
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: AuthStates.error,
          errorMessage: failure.message,
        ),
      ),
      (res) => emit(state.copyWith(state: AuthStates.loaded)),
    );
  }

  // isAuthenticated
  bool isAuthenticated() => (state.user != null) && (state.isAuthenticated == true);

  // sign out
  Future<void> signOut({String? error}) async {
    emit(state.copyWith(state: AuthStates.loading));
    final signOutUseCase = sl<SignOutUseCase>();
    final result = await signOutUseCase.call(const NoParams());
    result.fold(
        (failure) => emit(
              state.copyWith(
                state: AuthStates.error,
                errorMessage: failure.message,
                isAuthenticated: false,
              ),
            ), (user) {
      emit(
        state.copyWith(
          state: AuthStates.loaded,
          errorMessage: error,
          isAuthenticated: false,
        ),
      );
    });
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
    emit(state.copyWith(user: user));
    sl.authService.updateUserInStorage(user);
  }

  void setIsAuthenticated({required bool isAuthenticated}) => emit(state.copyWith(isAuthenticated: isAuthenticated));
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