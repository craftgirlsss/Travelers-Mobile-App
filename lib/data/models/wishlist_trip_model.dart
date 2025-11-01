// lib/data/models/wishlist_trip_model.dart

class WishlistTripModel {
  final String uuid;
  final String title;
  final String duration;
  final String location;
  final int price; // Dikonfirmasi sebagai int
  final int maxParticipants;
  final int discountPrice; // Dikonfirmasi sebagai int
  final String startDate;
  final String providerCompanyName;
  final String mainImageUrl;
  final String addedAt;

  WishlistTripModel({
    required this.uuid,
    required this.title,
    required this.duration,
    required this.location,
    required this.price,
    required this.maxParticipants,
    required this.discountPrice,
    required this.startDate,
    required this.providerCompanyName,
    required this.mainImageUrl,
    required this.addedAt,
  });

  factory WishlistTripModel.fromJson(Map<String, dynamic> json) {
    // Fungsi untuk mengonversi nilai numerik secara aman (menghindari String/int error)
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value.split('.').first) ?? 0;
      }
      return 0;
    }

    return WishlistTripModel(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      duration: json['duration'] as String,
      location: json['location'] as String,

      // Menggunakan safeParseInt untuk harga dan diskon
      price: safeParseInt(json['price']),
      discountPrice: safeParseInt(json['discount_price']),
      maxParticipants: safeParseInt(json['max_participants']),

      startDate: json['start_date'] as String,
      providerCompanyName: json['provider_company_name'] as String,
      mainImageUrl: json['main_image_url'] as String,
      addedAt: json['added_at'] as String,
    );
  }
}