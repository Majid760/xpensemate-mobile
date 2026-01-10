import 'package:xpensemate/features/profile/domain/usecases/update_profile_image_usecase.dart';
import 'package:xpensemate/features/profile/domain/usecases/update_profile_usecase.dart';

class ProfileUseCasesHolder {
  ProfileUseCasesHolder({
    required this.updateProfileUseCase,
    required this.updateProfileImageUseCase,
  });

  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateProfileImageUseCase updateProfileImageUseCase;
}
