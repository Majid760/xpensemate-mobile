import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_pagination_entity.dart';
import 'package:xpensemate/features/payment/domain/repositories/payment_repository.dart';

class GetPaymentsUseCase
    implements UseCase<PaymentPaginationEntity, GetPaymentsParams> {
  GetPaymentsUseCase(this.repository);
  final PaymentRepository repository;

  @override
  Future<Either<Failure, PaymentPaginationEntity>> call(
    GetPaymentsParams params,
  ) async =>
      repository.getPayments(params);
}

class GetPaymentsParams {
  GetPaymentsParams({
    required this.page,
    required this.limit,
    this.filterQuery,
  });
  final int page;
  String? filterQuery;
  final int limit;
}
