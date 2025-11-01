// lib/data/models/claimed_voucher_model.dart

class ClaimedVoucherModel {
  final String voucherUuid;
  final String claimStatus; // 'claimed' atau 'used'
  final String? claimedAt;
  final String? usedAt;
  final String code;
  final String type; // 'percentage' atau 'fixed'
  final double value;
  final String? imagePathUrl;
  final DateTime validUntil;
  final bool isExpired;

  ClaimedVoucherModel({
    required this.voucherUuid,
    required this.claimStatus,
    this.claimedAt,
    this.usedAt,
    required this.code,
    required this.type,
    required this.value,
    this.imagePathUrl,
    required this.validUntil,
    required this.isExpired,
  });

  factory ClaimedVoucherModel.fromJson(Map<String, dynamic> json) {
    return ClaimedVoucherModel(
      voucherUuid: json['voucher_uuid'] as String,
      claimStatus: json['claim_status'] as String,
      claimedAt: json['claimed_at'] as String?,
      usedAt: json['used_at'] as String?,
      code: json['code'] as String,
      type: json['type'] as String,
      value: double.parse(json['value'].toString()),
      imagePathUrl: json['image_path_url'] as String?,
      validUntil: DateTime.parse(json['valid_until'] as String),
      isExpired: json['is_expired'] as bool,
    );
  }
}