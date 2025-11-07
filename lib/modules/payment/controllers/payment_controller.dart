import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelers/data/models/payment_detail_model.dart';
import 'package:travelers/data/models/payment_method_model.dart';
import 'package:travelers/data/repositories/trip_repository.dart';

class PaymentController extends GetxController {
  final TripRepository _tripRepository = Get.find<TripRepository>();

  // Ambil argumen dari Get.toNamed()
  final String tripUuid = Get.arguments['tripUuid'] as String;
  final String bookingUuid = Get.arguments['bookingUuid'] as String;

  final isLoading = true.obs;
  final paymentDetails = Rxn<PaymentDetailModel>();
  final paymentMethods = <PaymentMethodModel>[].obs;
  final selectedMethod = Rxn<PaymentMethodModel>();

  final Rxn<XFile> proofImage = Rxn<XFile>();
  final noteController = TextEditingController();

  @override
  void onInit() {
    loadAllData();
    super.onInit();
  }

  // --- Load Data dari 2 API Sekaligus ---
  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      // Panggil kedua API secara paralel
      final results = await Future.wait([
        _tripRepository.getPaymentDetails(bookingUuid),
        _tripRepository.getPaymentMethods(tripUuid),
      ]);

      paymentDetails.value = results[0] as PaymentDetailModel?;
      paymentMethods.assignAll(results[1] as List<PaymentMethodModel>);

      // Set metode utama atau pertama sebagai default
      selectedMethod.value = paymentMethods.firstWhereOrNull((m) => m.isMain) ?? paymentMethods.firstOrNull;

      if (paymentDetails.value == null) {
        // Handle error: Detail tagihan tidak ditemukan
        Get.back();
        Get.snackbar('Error', 'Detail tagihan tidak ditemukan.', snackPosition: SnackPosition.BOTTOM);
      }

    } catch (e) {
      Get.log('Failed to load payment data: $e');
      Get.back(); // Kembali jika ada error fatal saat loading
    } finally {
      isLoading.value = false;
    }
  }

  // --- Actions ---
  void selectMethod(PaymentMethodModel method) {
    selectedMethod.value = method;
  }

  Future<void> pickProofImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      proofImage.value = pickedFile;
    }
  }

  Future<void> submitPaymentProof() async {
    final details = paymentDetails.value;
    if (selectedMethod.value == null) {
      Get.snackbar('Error', 'Pilih metode pembayaran terlebih dahulu.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (proofImage.value == null) {
      Get.snackbar('Error', 'Unggah bukti pembayaran.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (details == null) {
      Get.snackbar('Error', 'Detail tagihan tidak valid.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Tampilkan loading state
    isLoading.value = true;

    final success = await _tripRepository.submitPaymentProof(
      bookingUuid: bookingUuid,
      paymentMethodId: selectedMethod.value!.id,
      // 💥 Menggunakan total harga dari detail tagihan sebagai amount_paid
      amountPaid: details.totalPrice.toString(),
      notes: noteController.text.trim(),
      imagePath: proofImage.value!.path,
    );

    // Matikan loading
    isLoading.value = false;

    if (success) {
      // Navigasi ke halaman status booking setelah pembayaran
      Get.offNamedUntil('/booking-status', (route) => route.isFirst, arguments: {'uuid': bookingUuid});
      Get.snackbar('Sukses', 'Bukti pembayaran berhasil dikirim!', snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.green);
    } else {
      Get.snackbar('Gagal', 'Gagal mengirim bukti pembayaran. Coba lagi.', snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
    }
  }
}