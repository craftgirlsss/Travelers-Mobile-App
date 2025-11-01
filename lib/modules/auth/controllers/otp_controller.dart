import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:travelers/config/routes/app_routes.dart';

class OtpController extends GetxController {
  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  final TextEditingController otpC = TextEditingController();
  final RxBool isLoading = false.obs;

  // Data yang dilewatkan dari ForgotPasswordScreen
  final String userEmail = Get.arguments as String? ?? '';

  // Resend Timer State
  final RxInt resendSeconds = 60.obs;
  Timer? _timer;

  @override
  void onInit() {
    startResendTimer();
    super.onInit();
  }

  @override
  void onClose() {
    otpC.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // --- Timer Logics ---
  void startResendTimer() {
    _timer?.cancel();
    resendSeconds.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  String get timerText {
    if (resendSeconds.value == 0) return 'Kirim Ulang';
    return 'Kirim Ulang dalam ${resendSeconds.value}s';
  }

  // --- Validasi ---
  String? otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kode OTP tidak boleh kosong.';
    }
    if (value.length != 6) { // Asumsi kode OTP 6 digit
      return 'Kode OTP harus 6 digit.';
    }
    return null;
  }

  // --- API: Kirim Ulang OTP ---
  Future<void> resendOtp() async {
    if (resendSeconds.value > 0) return; // Jangan kirim jika timer masih berjalan

    // 💥 TODO: Panggil API Forgot Password lagi untuk request OTP baru
    // Untuk saat ini, kita hanya me-reset timer dan menampilkan pesan.
    startResendTimer();
    Get.snackbar(
      'Kode Dikirim Ulang',
      'Kode OTP baru telah dikirimkan ke $userEmail.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // --- API: Verifikasi OTP ---
  Future<void> verifyOtp() async {
    if (otpFormKey.currentState?.validate() ?? false) {
      isLoading.value = true;
      try {
        const String apiUrl = 'https://api-travelers.karyadeveloperindonesia.com/verify-otp';

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': userEmail,
            'otp_code': otpC.text,
          }),
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == true) {
          final resetToken = responseData['response']['reset_token']; // 💥 Ambil reset_token

          Get.snackbar(
            'Verifikasi Berhasil!',
            'Kode terverifikasi. Silakan atur kata sandi baru Anda.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
          );

          // 💥 NAVIGASI KE PAGE RESET PASSWORD DENGAN MENGIRIM EMAIL & TOKEN
          Get.offNamed(
              Routes.RESET_PASSWORD,
              arguments: {
                'email': userEmail,
                'reset_token': resetToken
              }
          );
        } else {
          // Gagal: Tampilkan pesan error
          String errorMessage = responseData['message'] ??
              'Kode OTP tidak valid atau kedaluwarsa.';
          Get.snackbar(
            'Gagal!',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // ... (Error handling)
      } finally {
        isLoading.value = false;
      }
    }
  }
}