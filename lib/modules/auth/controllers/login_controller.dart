// lib/modules/auth/controllers/login_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../data/models/user_model.dart';
import '../../../config/routes/app_routes.dart'; // Import rute

class LoginController extends GetxController {
  // Observables untuk state
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  // GlobalKey untuk validasi form

  // TextEditingController untuk input
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  // URL API Login (gunakan HTTPS)
  final String apiUrl = 'https://api-travelers.karyadeveloperindonesia.com/login';

  // Storage untuk token (GetStorage)
  final GetStorage box = GetStorage();

  // --- Validasi Email ---
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    // Regex sederhana untuk validasi format email
    if (!GetUtils.isEmail(value)) {
      return 'Masukkan format email yang valid.';
    }
    return null;
  }

  // --- Logika Login Email/Password ---
  Future<void> loginWithEmail() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailC.text,
          'password': passwordC.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        // Login Berhasil
        final UserModel user = UserModel.fromJson(responseData['response']);

        // Simpan token ke GetStorage
        await box.write('token', user.token);
        await box.write('refreshToken', user.refreshToken);
        await box.write('userData', responseData['response']); // Simpan data user

        Get.snackbar(
            'login_title'.tr,
            'Login berhasil! Selamat datang, ${user.name}',
            backgroundColor: Colors.green,
            colorText: Colors.white
        );

        // Navigasi ke halaman utama
        Get.offAllNamed(Routes.HOME);

        // PENTING: Hapus controller ini dari memori agar onClose() terpanggil.
        // Ini mencegah TextEditingController digunakan kembali setelah dibuang.
        Get.delete<LoginController>();

      } else {
        // Login Gagal (Status 401/200 dengan status: false)
        final String message = responseData['message'] ?? 'Terjadi kesalahan saat login.';
        errorMessage.value = message;
        Get.snackbar(
            'login_title'.tr,
            message,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Colors.white
        );
      }
    } catch (e) {
      errorMessage.value = 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
      Get.snackbar(
          'login_title'.tr,
          errorMessage.value,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white
      );
      print('Error Login: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Logika Login Sosial Media (Google & Facebook - Hanya Placeholder) ---
  void loginWithGoogle() {
    // Implementasi Google Sign-in di sini
    Get.snackbar('Fitur', 'Login dengan Google sedang dalam pengembangan.', snackPosition: SnackPosition.BOTTOM);
  }

  void loginWithFacebook() {
    // Implementasi Facebook Sign-in di sini
    Get.snackbar('Fitur', 'Login dengan Facebook sedang dalam pengembangan.', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    // Sudah benar dan PENTING: Membuang TextEditingController
    // emailC.dispose();
    // passwordC.dispose();
    super.onClose();
  }
}
