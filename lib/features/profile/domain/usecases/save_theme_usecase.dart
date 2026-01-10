import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';

class SaveThemeUseCase implements UseCase<void, ThemeMode> {
  SaveThemeUseCase(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(ThemeMode themeMode) =>
      repository.saveTheme(themeMode);
}
