import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/payment/data/models/payment_model.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_pagination_entity.dart';

class PaymentPaginationModel extends PaymentPaginationEntity {
  PaymentPaginationModel({
    required super.payments,
    required super.total,
    required super.page,
    required super.totalPages,
  });

  factory PaymentPaginationModel.fromEntity(PaymentPaginationEntity entity) =>
      PaymentPaginationModel(
        payments: entity.payments,
        total: entity.total,
        page: entity.page,
        totalPages: entity.totalPages,
      );

  factory PaymentPaginationModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json as Map<String, dynamic>? ?? {};

      final paymentsList = (data['payments'] as List<dynamic>?)
              ?.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return PaymentPaginationModel(
        payments: paymentsList.map((e) => e.toEntity()).toList(),
        total: _parseToInt(data['total']) ?? 0,
        page: _parseToInt(data['page']) ?? 1,
        totalPages: _parseToInt(data['totalPages']) ?? 1,
      );
    } on Exception catch (e) {
      AppLogger.e("error while parsing payment pagination model => $e");
      throw Exception(e);
    }
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'payments':
              payments.map((e) => (e as PaymentModel).toJson()).toList(),
          'total': total,
          'page': page,
          'totalPages': totalPages,
        },
      };

  PaymentPaginationEntity toEntity() => PaymentPaginationEntity(
        payments: payments,
        total: total,
        page: page,
        totalPages: totalPages,
      );

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value);
    }

    // Handle double values that might come from API
    if (value is double) {
      return value.toInt();
    }

    return null;
  }
}
