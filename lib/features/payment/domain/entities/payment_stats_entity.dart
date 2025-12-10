import 'package:equatable/equatable.dart';

class PaymentStatsEntity extends Equatable {
  const PaymentStatsEntity({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.averagePayment,
    required this.totalPayments,
    required this.walletBalance,
    required this.monthlyTrend,
    required this.revenueSources,
    required this.periodGrowth,
    required this.topPayer,
    required this.topPayerAmount,
  });

  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final double averagePayment;
  final int totalPayments;
  final double walletBalance;
  final List<MonthlyTrendEntity> monthlyTrend;
  final List<RevenueSourceEntity> revenueSources;
  final double periodGrowth;
  final String topPayer;
  final double topPayerAmount;

  @override
  List<Object?> get props => [
        period,
        startDate,
        endDate,
        totalAmount,
        averagePayment,
        totalPayments,
        walletBalance,
        monthlyTrend,
        revenueSources,
        periodGrowth,
        topPayer,
        topPayerAmount,
      ];
}

class MonthlyTrendEntity extends Equatable {
  const MonthlyTrendEntity({
    required this.month,
    required this.totalAmount,
  });

  final int month;
  final double totalAmount;

  @override
  List<Object?> get props => [month, totalAmount];
}

class RevenueSourceEntity extends Equatable {
  const RevenueSourceEntity({
    required this.paymentType,
    required this.totalAmount,
  });

  final String paymentType;
  final double totalAmount;

  @override
  List<Object?> get props => [paymentType, totalAmount];
}
