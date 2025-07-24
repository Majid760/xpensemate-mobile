import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/auth/domain/entities/auth_token.dart';

class AuthTokenModel extends Equatable {

  const AuthTokenModel({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokenModel.fromEntity(AuthToken token) => AuthTokenModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresIn: token.expiresAt != null
          ? token.expiresAt!.difference(DateTime.now()).inSeconds
          : 3600,
    );

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) => AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int? ?? 3600,
    );
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  Map<String, dynamic> toJson() => {
      'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };

  AuthToken toEntity() => AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}
