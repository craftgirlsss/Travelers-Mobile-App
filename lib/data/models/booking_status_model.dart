// lib/data/models/booking_status_model.dart

class BookingStatusModel {
  final bool booked;
  final String? bookingUuid; // UUID booking jika sudah dibooking
  final String? bookedDate;
  final bool paid;
  final String? paidAt;
  final String? status; // Contoh: 'pending', 'paid', 'cancelled'

  BookingStatusModel({
    required this.booked,
    this.bookingUuid,
    this.bookedDate,
    required this.paid,
    this.paidAt,
    this.status,
  });

  factory BookingStatusModel.fromJson(Map<String, dynamic> json) {
    return BookingStatusModel(
      booked: json['booked'] as bool,
      bookingUuid: json['booking_uuid'] as String?,
      bookedDate: json['booked_date'] as String?,
      paid: json['paid'] as bool,
      paidAt: json['paid_at'] as String?,
      status: json['status'] as String?,
    );
  }

  // 💥 FUNGSI COPYWITH
  BookingStatusModel copyWith({
    bool? booked,
    String? bookingUuid,
    String? bookedDate,
    bool? paid,
    String? paidAt,
    String? status,
  }) {
    return BookingStatusModel(
      booked: booked ?? this.booked,
      bookingUuid: bookingUuid ?? this.bookingUuid,
      bookedDate: bookedDate ?? this.bookedDate,
      paid: paid ?? this.paid,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
    );
  }
}