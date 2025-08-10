import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/auth/data/datasources/auth_local_storage.dart';
import 'package:xpensemate/features/auth/domain/usecases/cases_export.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> with ChangeNotifier {
  AuthCubit(this._authLocalDataSource) : super(const AuthState()) {
    _initializeAuth();
  }

  final AuthLocalDataSource _authLocalDataSource;

  Future<void> _initializeAuth() async {
    final userResult = await _authLocalDataSource.getStoredUser();
    userResult.fold(
      (failure) {
        // Failed to get user data, clear tokens and set as unauthenticated
        _authLocalDataSource.clearTokens();
        emit(
          state.copyWith(
            state: AuthStates.error,
            isAuthenticated: false,
            errorMessage: 'Failed to retrieve user data',
          ),
        );
      },
      (userModel) {
        if (userModel != null) {
          emit(
            state.copyWith(
              state: AuthStates.loaded,
              isAuthenticated: true,
              user: userModel.toEntity(),
            ),
          );
        } else {
          _authLocalDataSource.clearTokens();
          emit(
            state.copyWith(
              state: AuthStates.loaded,
              isAuthenticated: false,
            ),
          );
        }
      },
    );
  }

  /// login with email
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(state: AuthStates.loading));
    final loginUseCase = sl<SignInWithEmailUseCase>();
    final result = await loginUseCase
        .call(SignInWithEmailUseCaseParams(email: email, password: password));
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
          user: user.toModel,
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
    emit(state.copyWith(state: AuthStates.loading));
    final forgotPasswordUseCase = sl<ForgotPasswordUseCase>();
    final result = await forgotPasswordUseCase
        .call(ForgotPasswordUseCaseParams(email: email));
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
    final result = await sendVerificationEmailUseCase
        .call(SendVerificationEmailUseCaseParams(email: email));
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
  bool isAuthenticated() =>
      (state.user != null) && (state.isAuthenticated == true);

  // sign out
  Future<void> signOut() async {
    emit(state.copyWith(state: AuthStates.loading));
    final signOutUseCase = sl<SignOutUseCase>();
    final result = await signOutUseCase.call(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: AuthStates.error,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(state: AuthStates.loaded, isAuthenticated: false),
      ),
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
}

// add ssome nice extensions to get the controller in ui/widget
extension AuthCubitExtension on BuildContext {
  AuthCubit get authCubit => read<AuthCubit>();
}
