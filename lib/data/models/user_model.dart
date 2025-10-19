// lib/data/models/user_model.dart

class UserModel {
  final String uuid;
  final String name;
  final String email;
  final String role;
  final String token;
  final String refreshToken;
  final String tokenType;

  UserModel({
    required this.uuid,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.refreshToken,
    required this.tokenType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? '',
    );
  }
}