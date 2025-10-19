// lib/data/models/trip_model.dart

class ProviderModel {
  final String companyName;
  final String? companyLogoPath;

  ProviderModel({required this.companyName, this.companyLogoPath});

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      companyName: json['company_name'] ?? 'Unknown Provider',
      companyLogoPath: json['company_logo_path'],
    );
  }
}

class TripModel {
  final String uuid;
  final String title;
  final String duration;
  final String location;
  final int price;
  final int discountPrice;
  final int remainingSeats;
  final String startDate;
  final String? mainImageUrl;
  final ProviderModel provider;

  TripModel({
    required this.uuid,
    required this.title,
    required this.duration,
    required this.location,
    required this.price,
    required this.discountPrice,
    required this.remainingSeats,
    required this.startDate,
    this.mainImageUrl,
    required this.provider,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? 0,
      discountPrice: json['discount_price'] ?? 0,
      remainingSeats: json['remaining_seats'] ?? 0,
      startDate: json['start_date'] ?? '',
      mainImageUrl: json['main_image_url'],
      provider: ProviderModel.fromJson(json['provider'] ?? {}),
    );
  }
}