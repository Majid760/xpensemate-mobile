import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';

class PaymentPaginationEntity {
  PaymentPaginationEntity({
    required this.payments,
    required this.total,
    required this.page,
    required this.totalPages,
  });
  final List<PaymentEntity> payments;
  final int total;
  final int page;
  final int totalPages;

  PaymentPaginationEntity copyWith({
    List<PaymentEntity>? payments,
    int? total,
    int? page,
    int? totalPages,
  }) =>
      PaymentPaginationEntity(
        payments: payments ?? this.payments,
        total: total ?? this.total,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}
