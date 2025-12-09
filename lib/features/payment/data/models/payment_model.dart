import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.date,
    required super.payer,
    required super.paymentType,
    required super.notes,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PaymentModel.fromEntity(PaymentEntity entity) => PaymentModel(
        id: entity.id,
        userId: entity.userId,
        name: entity.name,
        amount: entity.amount,
        date: entity.date,
        payer: entity.payer,
        paymentType: entity.paymentType,
        notes: entity.notes,
        isDeleted: entity.isDeleted,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.parse(
          json['date'] as String? ?? DateTime.now().toIso8601String(),
        ),
        payer: json['payer'] as String? ?? '',
        paymentType: json['payment_type'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        isDeleted: json['is_deleted'] as bool? ?? false,
        createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user_id': userId,
        'name': name,
        'amount': amount,
        'date': date.toIso8601String(),
        'payer': payer,
        'payment_type': paymentType,
        'notes': notes,
        'is_deleted': isDeleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  PaymentEntity toEntity() => PaymentEntity(
        id: id,
        userId: userId,
        name: name,
        amount: amount,
        date: date,
        payer: payer,
        paymentType: paymentType,
        notes: notes,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
