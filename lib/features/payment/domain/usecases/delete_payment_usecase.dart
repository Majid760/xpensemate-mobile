import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/payment/domain/repositories/payment_repository.dart';

class DeletePaymentUseCase {
  DeletePaymentUseCase(this.repository);
  final PaymentRepository repository;

  Future<Either<Failure, bool>> call(String paymentId) async =>
      repository.deletePayment(paymentId);
}
