import 'package:xpensemate/features/profile/domain/usecases/get_theme_usecase.dart';
import 'package:xpensemate/features/profile/domain/usecases/save_theme_usecase.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_image_usecase.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_usecase.dart';

class ProfileUseCasesHolder {
  ProfileUseCasesHolder({
    required this.updateProfileUseCase,
    required this.updateProfileImageUseCase,
    required this.getThemeUseCase,
    required this.saveThemeUseCase,
  });

  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateProfileImageUseCase updateProfileImageUseCase;
  final GetThemeUseCase getThemeUseCase;
  final SaveThemeUseCase saveThemeUseCase;
}
