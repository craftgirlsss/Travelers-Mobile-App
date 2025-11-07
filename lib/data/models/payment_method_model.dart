class PaymentMethodModel {
  final int id;
  final String methodType; // QRIS, E_WALLET, BANK_TRANSFER
  final String accountName;
  final String bankName; // QRIS, OVO, BCA
  final String accountNumber;
  final String? qrisImageUrl;
  final bool isMain;

  PaymentMethodModel({
    required this.id,
    required this.methodType,
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    this.qrisImageUrl,
    required this.isMain,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as int? ?? 0,
      methodType: json['method_type'] ?? '',
      accountName: json['account_name'] ?? '',
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      qrisImageUrl: json['qris_image_url'],
      isMain: (json['is_main'] as int? ?? 0) == 1,
    );
  }
}