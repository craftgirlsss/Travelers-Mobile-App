// lib/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travelers/config/routes/app_routes.dart'; // Asumsi path routes Anda

class SettingController extends GetxController {
  // Asumsi Anda memiliki instance dari storage service
  final GetStorage box = GetStorage();

  // 💥 FUNGSI LOG OUT SESUNGGUHNYA
  Future<void> performLogout() async {
    Get.back(); // Tutup dialog konfirmasi terlebih dahulu

    // 1. TAMPILKAN LOADING (Opsional, tapi direkomendasikan)
    Get.showOverlay(
      asyncFunction: () async {
        // 2. HAPUS TOKEN & DATA PENGGUNA DARI LOCAL STORAGE
        await box.remove('token');
        await box.remove('refreshToken');
        await box.remove('userData'); // Simpan data user

        // 3. NAVIGASI KE HALAMAN LOGIN
        // Menggunakan offAll untuk membersihkan semua halaman stack
        Get.offAllNamed(Routes.LOGIN);

        // 4. TAMPILKAN SNACKBAR SUKSES
        Get.snackbar(
            'Status',
            'Anda telah berhasil keluar (Log Out).',
            snackPosition: SnackPosition.BOTTOM
        );
      },
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }
}