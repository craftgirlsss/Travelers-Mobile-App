// lib/modules/auth/controllers/register_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../config/routes/app_routes.dart';

class RegisterController extends GetxController {
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool termsAccepted = false.obs;

  // GlobalKey untuk validasi form
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // TextEditingController
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  // URL API Register
  final String apiUrl = 'https://api-travelers.karyadeveloperindonesia.com/register';

  // --- Validasi ---

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong.';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Masukkan format email yang valid.';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong.';
    }
    if (!GetUtils.isPhoneNumber(value) || value.length < 8) {
      return 'Masukkan nomor telepon yang valid.';
    }
    return null;
  }

  // Password harus minimal 8 karakter, huruf besar, huruf kecil, angka, dan simbol.
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong.';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter.';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf kapital.';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf kecil.';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka.';
    }
    if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>]|[^A-Za-z0-9\s])').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 simbol.';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong.';
    }
    if (value != passwordC.text) {
      return 'Konfirmasi password tidak cocok.';
    }
    return null;
  }

  // --- Logika Registrasi API ---
  Future<void> registerAccount() async {
    if (!registerFormKey.currentState!.validate()) {
      return;
    }
    if (!termsAccepted.value) {
      Get.snackbar('Kesalahan', 'Anda harus menyetujui syarat & ketentuan.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameC.text,
          'email': emailC.text,
          'phone': phoneC.text,
          'password': passwordC.text,
          'role': 'customer', // Hardcode role
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['status'] == true) {
        // Registrasi Berhasil
        Get.snackbar(
            'Registrasi Berhasil',
            'Akun berhasil dibuat! Silakan masuk.',
            backgroundColor: Colors.green,
            colorText: Colors.white
        );
        // Kembali ke halaman Login
        Get.offNamed(Routes.LOGIN);

      } else {
        // Registrasi Gagal
        final String message = responseData['message'] ?? 'Email sudah terdaftar atau terjadi kesalahan server.';
        Get.snackbar(
            'Registrasi Gagal',
            message,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar(
          'Kesalahan Koneksi',
          'Tidak dapat terhubung ke server. Coba lagi.',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white
      );
      print('Error Register: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Logika Signup Sosial Media (Placeholder) ---
  void socialSignup(String platform) {
    Get.snackbar('Fitur', 'Signup dengan $platform sedang dikembangkan.',
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }
}