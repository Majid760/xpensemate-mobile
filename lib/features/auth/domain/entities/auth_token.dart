import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/auth/data/models/auth_token_model.dart';
class AuthToken extends Equatable {

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  static const empty = AuthToken(accessToken: '');

  bool get isEmpty => this == AuthToken.empty;
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? true;

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) => AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );


  AuthTokenModel get toModel => AuthTokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresAt != null
          ? expiresAt!.difference(DateTime.now()).inSeconds
          : 3600,
    );

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}
