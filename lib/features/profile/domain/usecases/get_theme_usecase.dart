import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/profile/domain/repositories/profile_repository.dart';

class GetThemeUseCase implements UseCase<ThemeMode, NoParams> {
  GetThemeUseCase(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, ThemeMode>> call(NoParams params) =>
      repository.getTheme();
}
