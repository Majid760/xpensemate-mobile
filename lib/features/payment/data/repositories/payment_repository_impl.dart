import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_pagination_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';
import 'package:xpensemate/features/payment/domain/repositories/payment_repository.dart';
import 'package:xpensemate/features/payment/domain/usecases/get_payments_usecase.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this.remoteDataSource);
  final PaymentRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, bool>> createPayment({
    required PaymentEntity payment,
  }) =>
      remoteDataSource.createPayment(expense: payment);

  @override
  Future<Either<Failure, PaymentPaginationEntity>> getPayments(
    GetPaymentsParams params,
  ) async =>
      remoteDataSource.getPayments(
        page: params.page,
        limit: params.limit,
        filterQuery: params.filterQuery,
      );

  @override
  Future<Either<Failure, PaymentStatsEntity>> getPaymentStats(
    String? filterQuery,
  ) =>
      remoteDataSource.getPaymentStats(filterQuery: filterQuery);

  @override
  Future<Either<Failure, bool>> deletePayment(String paymentId) async =>
      remoteDataSource.deletePayment(paymentId);

  @override
  Future<Either<Failure, PaymentEntity>> getSinglePayment(
          String paymentId) async =>
      remoteDataSource.getSinglePayment(paymentId);

  @override
  Future<Either<Failure, PaymentEntity>> updatePayment(
    PaymentEntity payment,
  ) async =>
      remoteDataSource.updatePayment(payment);
}
