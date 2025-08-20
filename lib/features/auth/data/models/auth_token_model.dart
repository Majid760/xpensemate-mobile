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


  factory AuthTokenModel.fromJson(Map<String, dynamic> json){
    print("this is token data => $json");
    print("this is token keys => ${json.keys.toList()}");
    print("this is refreshToken value => ${json['refreshToken']}");
    print("this is refresh_token value => ${json['refresh_token']}");
    print("this is refresh value => ${json['refresh']}");
    
    return AuthTokenModel(
      accessToken: json['token'] as String? ?? (throw ArgumentError('token is required')),
      refreshToken: json['refreshToken'] as String? ?? json['refresh_token'] as String? ?? json['refresh'] as String?,
      expiresIn: int.tryParse(json['expiresIn'] as String) ?? 3600,
    );
  }
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
