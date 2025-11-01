import 'package:travelers/data/models/trip_model.dart'; // Mengambil ProviderModel jika diperlukan

// Model untuk detail transportasi internasional
class InternationalTransportModel {
  final String type;
  final String detail;

  InternationalTransportModel({required this.type, required this.detail});

  factory InternationalTransportModel.fromJson(Map<String, dynamic> json) {
    return InternationalTransportModel(
      type: json['type'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
    );
  }
}

class InternationalTripModel {
  final String uuid;
  final String title;
  final String duration;
  final String location;
  final String priceString; // Diterima sebagai String
  final String discountPriceString; // Diterima sebagai String
  final int maxParticipants;
  final int bookedParticipants;
  final int remainingSeats;
  final String startDate;
  final String mainImageUrl;
  final InternationalTransportModel internationalTransport;
  final ProviderModel provider;

  InternationalTripModel({
    required this.uuid,
    required this.title,
    required this.duration,
    required this.location,
    required this.priceString,
    required this.discountPriceString,
    required this.maxParticipants,
    required this.bookedParticipants,
    required this.remainingSeats,
    required this.startDate,
    required this.mainImageUrl,
    required this.internationalTransport,
    required this.provider,
  });

  // Helper untuk mendapatkan harga dalam format int/double
  double get price => double.tryParse(priceString) ?? 0.0;
  double get discountPrice => double.tryParse(discountPriceString) ?? 0.0;

  // Helper untuk mendapatkan URL gambar lengkap
  String get fullImageUrl => 'https://provider-travelers.karyadeveloperindonesia.com/$mainImageUrl';
  String get fullLogoUrl => 'https://provider-travelers.karyadeveloperindonesia.com/${provider.companyLogoPath}';


  factory InternationalTripModel.fromJson(Map<String, dynamic> json) {
    return InternationalTripModel(
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      location: json['location'] as String? ?? '',

      // 💥 Handle String yang menyebabkan error sebelumnya
      priceString: json['price'] as String? ?? '0.0',
      discountPriceString: json['discount_price'] as String? ?? '0.0',

      maxParticipants: json['max_participants'] as int? ?? 0,
      bookedParticipants: json['booked_participants'] as int? ?? 0,
      remainingSeats: json['remaining_seats'] as int? ?? 0,
      startDate: json['start_date'] as String? ?? '',
      mainImageUrl: json['main_image_url'] as String? ?? '',

      internationalTransport: InternationalTransportModel.fromJson(
        json['international_transport'] as Map<String, dynamic>? ?? {},
      ),
      provider: ProviderModel.fromJson(
        json['provider'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}