// Model respons yang disederhanakan untuk Booking
// Anda bisa membuat file model terpisah (misalnya BookingResponse.dart)
class BookingResponse {
  final bool success;
  final String message;
  final String? bookingUuid;
  final int? totalPrice;

  BookingResponse({
    required this.success,
    required this.message,
    this.bookingUuid,
    this.totalPrice,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      bookingUuid: json['booking_uuid'],
      totalPrice: json['total_price'] != null ? int.tryParse(json['total_price'].toString()) : null,
    );
  }
}