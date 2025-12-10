
import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_pagination_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';
import 'package:xpensemate/features/payment/domain/usecases/get_payments.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentPaginationEntity>> getPayments(
      GetPaymentsParams params);

  Future<Either<Failure, PaymentStatsEntity>> getPaymentStats();

  Future<Either<Failure, bool>> deletePayment(String paymentId);

  Future<Either<Failure, PaymentEntity>> getSinglePayment(String paymentId);

  Future<Either<Failure, PaymentEntity>> updatePayment(PaymentEntity payment);

  Future<Either<Failure, bool>> createPayment({
    required PaymentEntity payment,
  });
}
