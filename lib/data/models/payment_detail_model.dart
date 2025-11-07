class PaymentDetailModel {
  final String uuid; // Booking UUID
  final double totalPrice;
  final String bookingStatus;
  final String tripTitle;
  final String providerName;

  PaymentDetailModel({
    required this.uuid,
    required this.totalPrice,
    required this.bookingStatus,
    required this.tripTitle,
    required this.providerName,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) {
    final priceValue = json['total_price'];
    double totalPrice = 0.0;

    // Penanganan konversi totalPrice dari String/int/double
    if (priceValue != null) {
      if (priceValue is String) {
        // Hapus koma/titik jika ada dan parse
        totalPrice = double.tryParse(priceValue) ?? 0.0;
      } else if (priceValue is num) {
        totalPrice = priceValue.toDouble();
      }
    }

    return PaymentDetailModel(
      uuid: json['uuid'] ?? '',
      totalPrice: totalPrice,
      bookingStatus: json['booking_status'] ?? 'unknown',
      tripTitle: json['trip_title'] ?? 'Trip Title Unknown',
      providerName: json['provider_name'] ?? 'Provider Unknown',
    );
  }
}