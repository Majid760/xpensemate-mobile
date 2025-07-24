import 'package:dartz/dartz.dart';
import 'package:xpensemate/core/error/failures.dart';
import 'package:xpensemate/core/service/network_info_service.dart';


mixin NetworkCheckMixin<F extends Failure> {
  NetworkInfoService get networkInfo;

  Future<Either<F, R>> withNetworkCheck<Fail extends Failure, R>(
    Future<Either<F, R>> Function() callback,
  ) async {
    if (!networkInfo.isConnect) {
      return left(const NetworkFailure() as F);
    }
    return  callback();
  }
}