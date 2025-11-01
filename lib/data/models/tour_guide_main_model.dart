class TourGuideMainModel {
  final int guideId;
  final String name;
  final String phoneNumber;
  final String specialization;
  final String profilePhotoPath;

  TourGuideMainModel({
    required this.guideId,
    required this.name,
    required this.phoneNumber,
    required this.specialization,
    required this.profilePhotoPath,
  });

  factory TourGuideMainModel.fromJson(Map<String, dynamic> json) {
    return TourGuideMainModel(
      guideId: json['guide_id'] as int,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      specialization: json['specialization'] as String,
      profilePhotoPath: json['profile_photo_path'] as String,
    );
  }
}