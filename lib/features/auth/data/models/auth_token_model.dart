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

  factory AuthTokenModel.fromJson(Map<String, dynamic> jsonData) {
    try {
      var json = jsonData;
      if(jsonData.containsKey('data')){
        json = jsonData['data'] as Map<String, dynamic>;  
      }
      return AuthTokenModel(
        accessToken: json['token'] as String? ??
            (throw ArgumentError('token is required')),
        refreshToken: json['refreshToken'] as String? ??
            json['refresh_token'] as String? ??
            json['refresh'] as String?,
        expiresIn: json['expiresIn'] is String
            ? int.tryParse(json['expiresIn'] as String) ?? 3600
            : 3600,
      );
    } catch (e) {
      rethrow;
    }
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
