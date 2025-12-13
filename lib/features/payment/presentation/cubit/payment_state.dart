part of 'payment_cubit.dart';

enum PaymentStatus {
  initial,
  loading,
  loaded,
  error,
  loadingMore, // New state for loading additional pages
}

class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentStatus.initial,
    this.payments,
    this.paymentStats,
    this.message,
    this.stackTrace,
  });

  final PaymentStatus status;
  final PaymentPaginationEntity? payments;
  final PaymentStatsEntity? paymentStats;
  final String? message;
  final StackTrace? stackTrace;

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentPaginationEntity? payments,
    PaymentStatsEntity? paymentStats,
    String? message,
    StackTrace? stackTrace,
  }) =>
      PaymentState(
        status: status ?? this.status,
        payments: payments ?? this.payments,
        paymentStats: paymentStats ?? this.paymentStats,
        message: message ?? this.message,
        stackTrace: stackTrace ?? this.stackTrace,
      );

  @override
  List<Object?> get props => [
        status,
        payments,
        paymentStats,
        message,
        stackTrace,
      ];

  // Helper getters for UI logic
  bool get isInitialLoading =>
      status == PaymentStatus.loading && payments == null;
  bool get hasData => payments != null && payments!.payments.isNotEmpty;
  bool get hasError => status == PaymentStatus.error && payments == null;
}
