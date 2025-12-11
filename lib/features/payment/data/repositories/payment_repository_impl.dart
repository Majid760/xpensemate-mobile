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
  Future<Either<Failure, PaymentStatsEntity>> getPaymentStats() async {
    // Mock implementation for stats based on API response
    try {
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 500));

      return Right(
        PaymentStatsEntity(
          period: "monthly",
          startDate: DateTime.parse("2025-11-10T00:00:00.000Z"),
          endDate: DateTime.parse("2025-12-09T00:00:00.000Z"),
          totalAmount: 128902,
          averagePayment: 32225.5,
          totalPayments: 4,
          walletBalance: 125902,
          monthlyTrend: const [
            MonthlyTrendEntity(month: 1, totalAmount: 0),
            MonthlyTrendEntity(month: 2, totalAmount: 0),
            MonthlyTrendEntity(month: 3, totalAmount: 0),
            MonthlyTrendEntity(month: 4, totalAmount: 0),
            MonthlyTrendEntity(month: 5, totalAmount: 0),
            MonthlyTrendEntity(month: 6, totalAmount: 0),
            MonthlyTrendEntity(month: 7, totalAmount: 0),
            MonthlyTrendEntity(month: 8, totalAmount: 0),
            MonthlyTrendEntity(month: 9, totalAmount: 0),
            MonthlyTrendEntity(month: 10, totalAmount: 0),
            MonthlyTrendEntity(month: 11, totalAmount: 0),
            MonthlyTrendEntity(month: 12, totalAmount: 128902),
          ],
          revenueSources: const [
            RevenueSourceEntity(paymentType: "one_time", totalAmount: 123000),
            RevenueSourceEntity(paymentType: "salary", totalAmount: 5902),
          ],
          periodGrowth: 100,
          topPayer: "Company",
          topPayerAmount: 123000,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

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
