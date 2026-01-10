import 'package:xpensemate/features/auth/domain/usecases/cases_export.dart';

class AuthUseCasesHolder {
  AuthUseCasesHolder({
    required this.signInWithEmailUseCase,
    required this.signUpUseCase,
    required this.forgotPasswordUseCase,
    required this.signOutUseCase,
    required this.refreshTokenUseCase,
    required this.sendVerificationEmailUseCase,
  });
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final SignUpUseCase signUpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final SignOutUseCase signOutUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final SendVerificationEmailUseCase sendVerificationEmailUseCase;
}
