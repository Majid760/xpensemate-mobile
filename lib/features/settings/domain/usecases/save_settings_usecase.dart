import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/settings/domain/entities/settings_entity.dart';
import 'package:xpensemate/features/settings/domain/repositories/settings_repository.dart';

class SaveSettingsUseCase implements UseCase<void, SaveSettingsParams> {
  SaveSettingsUseCase(this.repository);

  final SettingsRepository repository;

  @override
  Future<Either<Failure, void>> call(SaveSettingsParams params) async => repository.updateSettings(params.settings);
}

class SaveSettingsParams extends Equatable {
  const SaveSettingsParams(this.settings);
  final SettingsEntity settings;

  @override
  List<Object> get props => [settings];
}
