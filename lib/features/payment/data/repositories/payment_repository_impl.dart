import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_pagination_entity.dart';
import 'package:xpensemate/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this.remoteDataSource);
  final PaymentRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, bool>> createPayment({
    required PaymentEntity payment,
  }) =>
      remoteDataSource.createPayment(expense: payment);

  @override
  Future<Either<Failure, PaymentPaginationEntity>> getPayments({
    required int page,
    required int limit,
    String? filterQuery,
  }) async =>
      remoteDataSource.getPayments(
        page: page,
        limit: limit,
        filterQuery: filterQuery,
      );

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
