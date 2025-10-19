// lib/data/models/trip_detail_model.dart

import 'trip_model.dart'; // Impor ProviderModel dari TripModel

class TripImageModel {
  final String imageUrl;
  final bool isMain;

  TripImageModel({required this.imageUrl, required this.isMain});

  factory TripImageModel.fromJson(Map<String, dynamic> json) {
    return TripImageModel(
      // Tambahkan base URL gambar Anda di sini
      imageUrl: 'https://provider-travelers.karyadeveloperindonesia.com/${json['image_url'] ?? ''}',
      isMain: (json['is_main'] ?? 0) == 1,
    );
  }
}

class TripDetailModel {
  final String uuid;
  final String title;
  final String description;
  final String duration;
  final String location;
  final int price;
  final int discountPrice;
  final int remainingSeats;
  final String startDate;
  final String departureTime;
  final String returnTime;
  final ProviderModel provider;
  final List<TripImageModel> images;

  // Data tambahan yang tidak ada di API tapi dibutuhkan untuk UI placeholder
  final double rating;
  final double distanceKm;
  final double tempC;

  TripDetailModel({
    required this.uuid,
    required this.title,
    required this.description,
    required this.duration,
    required this.location,
    required this.price,
    required this.discountPrice,
    required this.remainingSeats,
    required this.startDate,
    required this.departureTime,
    required this.returnTime,
    required this.provider,
    required this.images,
    // Placeholder Data
    this.rating = 4.8,
    this.distanceKm = 5.5,
    this.tempC = 25.0,
  });

  factory TripDetailModel.fromJson(Map<String, dynamic> json) {
    final List<TripImageModel> imageList = (json['images'] as List?)
        ?.map((i) => TripImageModel.fromJson(i))
        .toList() ?? [];

    return TripDetailModel(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      location: json['location'] ?? '',
      price: json.containsKey('price') ? json['price'] : 0,
      discountPrice: json.containsKey('discount_price') ? json['discount_price'] : 0,
      remainingSeats: json.containsKey('remaining_seats') ? json['remaining_seats'] : 0,
      startDate: json['start_date'] ?? '',
      departureTime: json['departure_time'] ?? '',
      returnTime: json['return_time'] ?? '',
      provider: ProviderModel.fromJson(json['provider'] ?? {}),
      images: imageList,
    );
  }
}