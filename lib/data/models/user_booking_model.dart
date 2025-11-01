// lib/data/models/user_booking_model.dart

class UserBookingModel {
  final String bookingUuid;
  final String tripUuid;
  final String tripTitle;
  final String providerName;
  final String location;
  // Ubah ke DateTime atau biarkan String, tapi komentar Anda benar, DateTime lebih baik
  final String startDate;
  final String departureTime;
  final int numOfPeople;
  final int totalPrice;
  final String status; // 'pending', 'paid', 'cancelled', dll.
  final String bookingDate;

  UserBookingModel({
    required this.bookingUuid,
    required this.tripUuid,
    required this.tripTitle,
    required this.providerName,
    required this.location,
    required this.startDate,
    required this.departureTime,
    required this.numOfPeople,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
  });

  factory UserBookingModel.fromJson(Map<String, dynamic> json) {
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      // Memperbaiki parsing string:
      if (value is String) return int.tryParse(value.split('.').first) ?? 0;
      return 0;
    }

    return UserBookingModel(
      bookingUuid: json['booking_uuid'] as String,
      tripUuid: json['trip_uuid'] as String,
      tripTitle: json['trip_title'] as String,
      providerName: json['provider_name'] as String,
      location: json['location'] as String,
      startDate: json['start_date'] as String,
      departureTime: json['departure_time'] as String,
      numOfPeople: safeParseInt(json['num_of_people']),
      totalPrice: safeParseInt(json['total_price']),
      status: json['status'] as String,
      bookingDate: json['booking_date'] as String,
    );
  }
}