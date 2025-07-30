import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';

enum AuthStates { initial, loading, loaded, error }


class AuthState extends Equatable {

const AuthState({
  this.state = AuthStates.initial,
  this.isAuthenticated = false,
  this.user,
  this.errorMessage,
  this.stackTrace,
});

final AuthStates state;
final UserModel? user;
final String? errorMessage;
final StackTrace? stackTrace;
final bool isAuthenticated;

AuthState copyWith({
  AuthStates? state,
  UserModel? user,
  String? errorMessage,
  StackTrace? stackTrace,
  bool? isAuthenticated,
}) => AuthState(
    state: state ?? this.state,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    stackTrace: stackTrace ?? this.stackTrace,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
  );

  @override
  List<Object?> get props => [state, user,isAuthenticated, errorMessage, stackTrace];
}
