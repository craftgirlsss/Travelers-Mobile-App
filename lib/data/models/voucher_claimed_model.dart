// lib/data/models/voucher_model.dart

class VoucherClaimedModel {
  String uuid;
  String? code;
  String? type; // 'percentage' atau 'fixed'
  double? value;
  String? imagePath;
  double? minPurchase;
  DateTime? validUntil;
  int? remainingVouchers;
  String? voucherUuid;
  String? claimStatus;

  VoucherClaimedModel({
    required this.uuid,
    this.code,
    this.type,
    this.value,
    this.imagePath,
    this.minPurchase,
    this.validUntil,
    this.remainingVouchers,
    this.claimStatus,
    this.voucherUuid
  });

  factory VoucherClaimedModel.fromJson(Map<String, dynamic> json) {
    // Parsing String ke Double
    double parseDouble(dynamic value) {
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }

    // Parsing image path dengan base URL (sesuaikan jika base URL berbeda)
    String? rawPath = json['image_path'];
    String? fullImagePath = rawPath != null
        ? 'https://provider-travelers.karyadeveloperindonesia.com/$rawPath'
        : null;

    return VoucherClaimedModel(
      uuid: json['uuid'] ?? '',
      code: json['code'] ?? 'N/A',
      type: json['type'] ?? 'fixed',
      value: parseDouble(json['value']),
      imagePath: fullImagePath,
      minPurchase: parseDouble(json['min_purchase']),
      validUntil: DateTime.tryParse(json['valid_until'] ?? '') ?? DateTime.now(),
      remainingVouchers: json['remaining_vouchers'] ?? 0,
      voucherUuid: json['voucher_uuid'] as String,
      claimStatus: json['claim_status'] as String,
    );
  }
}