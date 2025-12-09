import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/domain/repositories/payment_repository.dart';

class UpdatePaymentUseCase {
  UpdatePaymentUseCase(this.repository);
  final PaymentRepository repository;

  Future<Either<Failure, PaymentEntity>> call(PaymentEntity payment) async =>
      repository.updatePayment(payment);
}
