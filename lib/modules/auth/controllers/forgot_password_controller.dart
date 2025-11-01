import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:travelers/config/routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailC.dispose();
    super.onClose();
  }

  // --- Validasi ---
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  // --- Pemanggilan API Reset Password ---
  Future<void> sendResetRequest() async {
    if (forgotPasswordFormKey.currentState?.validate() ?? false) {
      isLoading.value = true;
      try {
        const String apiUrl = 'https://api-travelers.karyadeveloperindonesia.com/forgot-password';

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': emailC.text}),
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          // Sukses: Tampilkan pesan dan navigasi ke halaman OTP atau Login
          Get.snackbar(
            'Berhasil!',
            responseData['message'] ?? 'Kode OTP telah dikirimkan ke email Anda.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
          );

          // 💥 TODO: Ganti ini dengan navigasi ke halaman verifikasi OTP
          Get.toNamed(Routes.OTP_VERIFICATION, arguments: emailC.text);

        } else {
          // Gagal: Tampilkan pesan error
          String errorMessage = responseData['message'] ?? 'Gagal mengirim permintaan reset password. Coba lagi.';
          Get.snackbar(
            'Gagal!',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.log("Error during forgot password request: $e");
        Get.snackbar(
          'Error Jaringan',
          'Tidak dapat terhubung ke server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}
