// lib/data/models/profile_model.dart

class ProfileModel {
  final String uuid;
  final String name;
  final String email;
  final String? phone;
  String? gender;
  String? birthDate;
  String? address;
  String? province;
  String? city;
  String? postalCode;
  String? detailPictureUrl;
  final String role;
  final String? profilePictureUrl;

  ProfileModel({
    required this.uuid,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.birthDate,
    this.address,
    this.province,
    this.city,
    this.postalCode,
    this.detailPictureUrl,
    required this.role,
    this.profilePictureUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      address: json['address'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      role: json['role'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      detailPictureUrl: json['detail_picture_url']
    );
  }
}