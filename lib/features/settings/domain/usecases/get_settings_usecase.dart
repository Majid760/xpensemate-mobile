import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/settings/domain/entities/settings_entity.dart';
import 'package:xpensemate/features/settings/domain/repositories/settings_repository.dart';

class GetSettingsUseCase implements UseCase<SettingsEntity, NoParams> {
  GetSettingsUseCase(this.repository);

  final SettingsRepository repository;

  @override
  Future<Either<Failure, SettingsEntity>> call(NoParams params) async => repository.getSettings();
}
