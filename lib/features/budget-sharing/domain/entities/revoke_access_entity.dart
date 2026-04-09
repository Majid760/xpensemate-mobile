import 'package:equatable/equatable.dart';

class RevokeAccessEntity extends Equatable {
  const RevokeAccessEntity({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}
