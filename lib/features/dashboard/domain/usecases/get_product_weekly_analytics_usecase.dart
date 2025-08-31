import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/dashboard/domain/entities/product_weekly_analytics_entity.dart';
import 'package:xpensemate/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetProductWeeklyAnalyticsUseCase extends UseCase<ProductWeeklyAnalyticsEntity, NoParams> {
  GetProductWeeklyAnalyticsUseCase(this.repository);
  
  final DashboardRepository repository;

  @override
  Future<Either<Failure, ProductWeeklyAnalyticsEntity>> call(NoParams params) =>
      repository.getProductWeeklyAnalytics();
}