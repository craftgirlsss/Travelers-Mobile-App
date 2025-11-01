import 'tour_guide_main_model.dart';

class TourGuideModel {
  final bool hasTourGuide;
  final TourGuideMainModel? mainGuide;

  TourGuideModel({
    required this.hasTourGuide,
    this.mainGuide,
  });

  factory TourGuideModel.fromJson(Map<String, dynamic> json) {
    final mainGuideData = json['main_guide'] as Map<String, dynamic>?; // Menerima null

    return TourGuideModel(
      hasTourGuide: json['has_tour_guide'] as bool,
      mainGuide: mainGuideData != null ? TourGuideMainModel.fromJson(mainGuideData) : null,
    );
  }
}