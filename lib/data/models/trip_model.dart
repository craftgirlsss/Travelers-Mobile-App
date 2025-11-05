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
  String? startDate;
  String? mainImageUrl;
  ProviderModel provider;

  TripModel({
    required this.uuid,
    required this.title,
    required this.duration,
    required this.location,
    required this.price,
    required this.discountPrice,
    required this.remainingSeats,
    this.startDate,
    this.mainImageUrl,
    required this.provider,
  });

  // 💥 Fungsi Helper untuk Parsing yang Aman
  static int _parseIntValue(dynamic value) {
    if (value == null) {
      return 0;
    }
    // Jika sudah berupa int, langsung kembalikan
    if (value is int) {
      return value;
    }
    // Jika berupa string, coba parsing. Jika gagal, kembalikan 0.
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    // Untuk kasus lain (misalnya double, meskipun tidak diharapkan), lakukan konversi
    if (value is double) {
      return value.toInt();
    }
    return 0; // Default jika tipe data tidak dikenal
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      location: json['location'] ?? '',

      // 💥 Menggunakan fungsi helper untuk konversi price
      price: _parseIntValue(json['price']),

      // 💥 Menggunakan fungsi helper untuk konversi discountPrice
      discountPrice: _parseIntValue(json['discount_price']),

      // 💥 Menggunakan fungsi helper untuk konversi remainingSeats
      remainingSeats: _parseIntValue(json['remaining_seats']),

      startDate: json['start_date'] ?? '',
      // Main image URL mungkin null, jadi biarkan saja
      mainImageUrl: json['main_image_url'],
      provider: ProviderModel.fromJson(json['provider'] ?? {}),
    );
  }
}