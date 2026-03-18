import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsEntity>> getSettings();
  Future<Either<Failure, void>> updateSettings(SettingsEntity settings);
}
