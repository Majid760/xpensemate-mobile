import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/domain/repositories/payment_repository.dart';

class CreatePaymentUseCase {
  CreatePaymentUseCase(this.repository);
  final PaymentRepository repository;

  Future<Either<Failure, bool>> call(PaymentEntity payment) async =>
      repository.createPayment(payment: payment);
}
