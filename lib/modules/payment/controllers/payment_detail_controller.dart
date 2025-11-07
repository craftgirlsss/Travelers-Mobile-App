import 'package:get/get.dart';

class PaymentDetailController extends GetxController {
  final String bookingUuid = Get.arguments as String;
  final RxBool isLoading = true.obs;
  final RxInt totalPrice = 5500000.obs;
  final RxString paymentMethod = 'Bank Transfer BNI'.obs;
  final RxString virtualAccountNumber = '88801234567890'.obs;
  final Rx<DateTime> dueDate = Rx<DateTime>(DateTime.now().add(const Duration(hours: 24)));

  @override
  void onInit() {
    fetchPaymentDetails();
    super.onInit();
  }

  Future<void> fetchPaymentDetails() async {
    isLoading.value = true;

    // --- Implementasi API Call di sini ---
    // try {
    //   final detail = await _repository.fetchPaymentDetail(bookingUuid);
    //   paymentDetail.value = detail;
    //   // Update state lain berdasarkan detail yang diterima
    // } catch (e) {
    //   Get.snackbar('Error', 'Gagal memuat detail pembayaran.', snackPosition: SnackPosition.BOTTOM);
    // }

    // Simulasi loading
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  void copyVaNumber() {
    Get.snackbar('Sukses', 'Nomor VA berhasil disalin.', snackPosition: SnackPosition.BOTTOM);
  }

  void viewPaymentInstructions() {
    Get.snackbar('Instruksi', 'Mengarahkan ke halaman instruksi pembayaran.', snackPosition: SnackPosition.BOTTOM);
  }
}