import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failure.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';
import 'package:xpensemate/features/payment/domain/repositories/payment_repository.dart';

class GetPaymentStatsUseCase
    implements UseCase<PaymentStatsEntity, NoParams> {
  GetPaymentStatsUseCase(this.repository);
  final PaymentRepository repository;

  @override
  Future<Either<Failure, PaymentStatsEntity>> call(NoParams params) =>
      repository.getPaymentStats();
}
