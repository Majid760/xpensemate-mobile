import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/auth/data/models/user_model.dart';


class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const empty = User(id: '', email: '');

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => this != User.empty;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );


    UserModel get toModel => UserModel(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];
}
