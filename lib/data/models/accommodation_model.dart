class AccommodationModel {
  final bool hasAccommodation;
  final String? details; // Sudah nullable

  AccommodationModel({
    required this.hasAccommodation,
    this.details,
  });

  factory AccommodationModel.fromJson(Map<String, dynamic> json) {
    return AccommodationModel(
      hasAccommodation: json['has_accommodation'] as bool,
      details: json['details'] as String?,
    );
  }
}