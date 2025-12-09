import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    required this.payer,
    required this.paymentType,
    required this.notes,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final double amount;
  final DateTime date;
  final String payer;
  final String paymentType;
  final String notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    DateTime? date,
    String? payer,
    String? paymentType,
    String? notes,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      PaymentEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        payer: payer ?? this.payer,
        paymentType: paymentType ?? this.paymentType,
        notes: notes ?? this.notes,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        amount,
        date,
        payer,
        paymentType,
        notes,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
