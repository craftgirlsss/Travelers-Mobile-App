import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:travelers/config/routes/app_routes.dart';

class ResetPasswordController extends GetxController {
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();
  final RxBool isLoading = false.obs;

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Data yang dilewatkan dari OtpVerificationScreen
  late final String userEmail;
  late final String resetToken;

  @override
  void onInit() {
    final args = Get.arguments as Map<String, dynamic>?;
    userEmail = args?['email'] ?? '';
    resetToken = args?['reset_token'] ?? '';

    // Lakukan pemeriksaan sederhana jika data penting hilang
    if (userEmail.isEmpty || resetToken.isEmpty) {
      Get.offAllNamed(Routes.LOGIN); // Redirect jika data tidak lengkap
      Get.snackbar('Error', 'Sesi reset password tidak valid.', snackPosition: SnackPosition.BOTTOM);
    }
    super.onInit();
  }

  @override
  void onClose() {
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }

  // --- Validasi ---
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong.';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong.';
    }
    if (value != passwordC.text) {
      return 'Konfirmasi kata sandi tidak cocok.';
    }
    return null;
  }

  // --- API: Reset Password ---
  Future<void> resetPassword() async {
    if (resetPasswordFormKey.currentState?.validate() ?? false) {
      isLoading.value = true;
      try {
        const String apiUrl = 'https://api-travelers.karyadeveloperindonesia.com/reset-password';

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': userEmail,
            'reset_token': resetToken,
            'new_password': passwordC.text,
          }),
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          // Sukses: Tampilkan pesan dan navigasi ke halaman Login
          Get.snackbar(
            'Berhasil!',
            'Kata sandi Anda telah berhasil diubah. Silakan masuk.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
          );

          Get.offAllNamed(Routes.LOGIN);

        } else {
          // Gagal: Tampilkan pesan error
          String errorMessage = responseData['message'] ?? 'Gagal mereset kata sandi. Token mungkin sudah kedaluwarsa.';
          Get.snackbar(
            'Gagal!',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.log("Error during password reset: $e");
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