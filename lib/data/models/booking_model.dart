// lib/data/models/booking_model.dart

class BookingModel {
  final String bookingUuid;
  final String tripUuid;
  final String tripTitle;
  final String providerName;
  final String location;
  final String startDate; // Perlu diubah ke DateTime jika ingin membandingkan
  final String departureTime;
  final int numOfPeople;
  final int totalPrice;
  final String status; // pending, paid, cancelled, dll.
  final String bookingDate;

  BookingModel({
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

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value.split('.').first) ?? 0;
      return 0;
    }

    return BookingModel(
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