import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/budget_share_entity.dart';

abstract class BudgetSharingState extends Equatable {
  const BudgetSharingState();

  @override
  List<Object?> get props => [];
}

class BudgetSharingInitial extends BudgetSharingState {}

class BudgetSharingLoading extends BudgetSharingState {}

class BudgetSharingSuccess extends BudgetSharingState {
  const BudgetSharingSuccess(this.result);

  final BudgetShareResultEntity result;

  @override
  List<Object?> get props => [result];
}

class BudgetSharingError extends BudgetSharingState {
  const BudgetSharingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AcceptInviteLoading extends BudgetSharingState {}

class AcceptInviteSuccess extends BudgetSharingState {
  const AcceptInviteSuccess(this.result);

  final BudgetShareEntity result;

  @override
  List<Object?> get props => [result];
}

class AcceptInviteError extends BudgetSharingState {
  const AcceptInviteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
