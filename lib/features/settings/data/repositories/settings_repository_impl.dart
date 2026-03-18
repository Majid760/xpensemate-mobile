import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:xpensemate/features/settings/data/models/settings_model.dart';
import 'package:xpensemate/features/settings/domain/entities/settings_entity.dart';
import 'package:xpensemate/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this.localDataSource);

  final SettingsLocalDataSource localDataSource;

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } on Exception catch (e) {
      logE('Error in SettingsRepositoryImpl.getSettings: $e');
      return const Left(LocalDataFailure(message: 'Failed to load settings.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(SettingsEntity settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(settingsModel);
      return const Right(null);
    } on Exception catch (e) {
      logE('Error in SettingsRepositoryImpl.updateSettings: $e');
      return const Left(LocalDataFailure(message: 'Failed to save settings.'));
    }
  }
}
