import 'package:xpensemate/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:xpensemate/features/settings/domain/usecases/save_settings_usecase.dart';

class SettingsUseCasesHolder {
  SettingsUseCasesHolder({
    required this.getSettingsUseCase,
    required this.saveSettingsUseCase,
  });

  final GetSettingsUseCase getSettingsUseCase;
  final SaveSettingsUseCase saveSettingsUseCase;
}
