// lib/data/models/profile_model.dart

class ProfileModel {
  final String uuid;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profilePictureUrl;

  ProfileModel({
    required this.uuid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profilePictureUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}