import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/auth/domain/entities/user.dart';
import 'package:xpensemate/features/auth/domain/usecases/forgot_password_usercase.dart';
import 'package:xpensemate/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:xpensemate/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:xpensemate/features/auth/domain/usecases/use_cases_holder.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> with ChangeNotifier {
  AuthCubit(
    this._useCasesHolder,
  ) : super(const AuthInitial()) {
    _userSubscription = sl.authService.userStream.listen((user) {
      if (user != null) {
        AppLogger.setUserId(user.id);
        AppLogger.setCustomKey('is_authenticated', true);
        emit(AuthAuthenticated(user));
      } else {
        AppLogger.setCustomKey('is_authenticated', false);
        emit(const AuthUnauthenticated());
      }
    });
  }

  final AuthUseCasesHolder _useCasesHolder;
  late final StreamSubscription<UserEntity?> _userSubscription;

  bool get isAuthenticated => state is AuthAuthenticated;

  Future<void> initializeAuth() async {
    if (!sl.authService.isInitialized) {
      await sl.authService.initializeService();
    }

    final user = sl.authService.currentUser;

    if (user != null) {
      AppLogger.setUserId(user.id);
      AppLogger.setCustomKey('is_authenticated', true);
      emit(AuthAuthenticated(user));
    } else {
      AppLogger.setCustomKey('is_authenticated', false);
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await _useCasesHolder.signInWithEmailUseCase.call(
      SignInWithEmailUseCaseParams(email: email, password: password),
    );
    result.fold(
      (failure) {
        AppLogger.breadcrumb('Login failed');
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.setUserId(user.id);
        AppLogger.setCustomKey('is_authenticated', true);
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await _useCasesHolder.signUpUseCase.call(
      SignUpUseCaseParams(
        fullName: fullName,
        email: email,
        password: password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> forgotPassword({required String email}) async {
    emit(const AuthLoading());

    final result = await _useCasesHolder.forgotPasswordUseCase.call(
      ForgotPasswordUseCaseParams(email: email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> updateUser(UserEntity user) async {
    emit(AuthAuthenticated(user));
  }

  Future<void> signOut({String? error}) async {
    emit(const AuthLoading());

    final result = await _useCasesHolder.signOutUseCase.call(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        AppLogger.reset();
        emit(const AuthUnauthenticated());
      },
    );
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  UserEntity? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;
}

// extension for AuthCubit
extension AuthCubitExtension on BuildContext {
  /// don't get cubit directly from service locator
  /// use this extension to get cubit (it will fetch the controller form tree)
  AuthCubit get authCubit => read<AuthCubit>();
}
