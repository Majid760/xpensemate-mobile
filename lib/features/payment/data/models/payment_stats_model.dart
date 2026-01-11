import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';

class PaymentStatsModel extends PaymentStatsEntity {
  const PaymentStatsModel({
    required super.period,
    required super.startDate,
    required super.endDate,
    required super.totalAmount,
    required super.averagePayment,
    required super.totalPayments,
    required super.walletBalance,
    required super.monthlyTrend,
    required super.revenueSources,
    required super.periodGrowth,
    required super.topPayer,
    required super.topPayerAmount,
  });

  factory PaymentStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentStatsModel(
        period: json['period'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        averagePayment: (json['avgPayment'] as num?)?.toDouble() ?? 0.0,
        totalPayments: json['totalPayments'] as int,
        walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
        monthlyTrend: (json['monthlyTrend'] as List)
            .map((e) => MonthlyTrendModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        revenueSources: (json['revenueSources'] as List)
            .map((e) => RevenueSourceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        periodGrowth: (json['periodGrowth'] as num?)?.toDouble() ?? 0.0,
        topPayer: (json['topPayer'] as String?) ?? '',
        topPayerAmount: (json['topPayerAmount'] as num?)?.toDouble() ?? 0.0,
      );
    } on Exception catch (_) {
      rethrow;
    }
  }
}

class MonthlyTrendModel extends MonthlyTrendEntity {
  const MonthlyTrendModel({
    required super.month,
    required super.totalAmount,
  });

  factory MonthlyTrendModel.fromJson(Map<String, dynamic> json) {
    try {
      return MonthlyTrendModel(
        month: json['month'] as int,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      );
    } on Exception catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'totalAmount': totalAmount,
      };
}

class RevenueSourceModel extends RevenueSourceEntity {
  const RevenueSourceModel({
    required super.paymentType,
    required super.totalAmount,
  });

  factory RevenueSourceModel.fromJson(Map<String, dynamic> json) {
    try {
      return RevenueSourceModel(
        paymentType: json['payment_type'] as String,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      );
    } on Exception catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'payment_type': paymentType,
        'totalAmount': totalAmount,
      };
}
