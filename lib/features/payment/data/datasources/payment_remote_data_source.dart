import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/network/network_configs.dart';
import 'package:xpensemate/core/network/network_contracts.dart';
import 'package:xpensemate/features/payment/data/models/payment_model.dart';
import 'package:xpensemate/features/payment/data/models/payment_pagination_model.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';

sealed class PaymentRemoteDataSource {
  Future<Either<Failure, bool>> createPayment({required PaymentEntity expense});

  /// Fetches payments with pagination (matches web app: /payments?page=${page}&limit=${limit})
  Future<Either<Failure, PaymentPaginationModel>> getPayments({
    required int page,
    required int limit,
    String? filterQuery,
  });

  // /// Fetches payment statistics
  // Future<Either<Failure, PaymentStatsModel>> getPaymentStats({
  //   String? period,
  // });

  /// Update an payment
  Future<Either<Failure, PaymentEntity>> getSinglePayment(String paymentId);

  /// Delete an payment
  Future<Either<Failure, bool>> deletePayment(String paymentIdd);

  /// Update an payment
  Future<Either<Failure, PaymentEntity>> updatePayment(PaymentEntity payment);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._networkClient);
  final NetworkClient _networkClient;

  @override
  Future<Either<Failure, bool>> createPayment({
    required PaymentEntity expense,
  }) {
    final paymentModel = PaymentModel.fromEntity(expense).toJson();
    paymentModel.remove('_id');
    return _networkClient.post(
      NetworkConfigs.createPayment,
      data: paymentModel,
      fromJson: (json) => json['data'] as bool? ?? true,
    );
  }

  @override
  Future<Either<Failure, PaymentPaginationModel>> getPayments({
    required int page,
    required int limit,
    String? filterQuery,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'filterQuery': filterQuery ?? '',
    };
    return _networkClient.get(
      NetworkConfigs.getPayments,
      query: queryParams,
      fromJson: PaymentPaginationModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, bool>> deletePayment(String paymentIdd) =>
      _networkClient.delete<bool>(
        NetworkConfigs.deletePayment.replaceAll(':id', paymentIdd),
        fromJson: (json) => json['data'] as bool? ?? true,
      );

  @override
  Future<Either<Failure, PaymentEntity>> getSinglePayment(String paymentId) =>
      _networkClient.get<PaymentEntity>(
        NetworkConfigs.getSinglePayment.replaceAll(':id', paymentId),
        fromJson: PaymentModel.fromJson,
      );

  @override
  Future<Either<Failure, PaymentEntity>> updatePayment(PaymentEntity payment) {
    final paymentModel = PaymentModel.fromEntity(payment);
    return _networkClient.put(
      '${NetworkConfigs.updatePayment}/${payment.id}',
      data: paymentModel.toJson(),
      fromJson: PaymentModel.fromJson,
    );
  }
}
