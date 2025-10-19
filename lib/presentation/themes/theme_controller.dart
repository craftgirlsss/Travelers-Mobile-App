import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  // Kunci untuk menyimpan tema di GetStorage
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // State reaktif (RxBool) untuk tema gelap
  // Nilai awal diambil dari GetStorage, default ke false (terang) jika belum ada.
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi state dari penyimpanan lokal saat controller dibuat
    isDarkMode.value = _loadThemeFromBox();
  }

  // Memuat tema dari GetStorage
  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  // Menyimpan tema ke GetStorage
  _saveThemeToBox(bool isDark) => _box.write(_key, isDark);

  // Mendapatkan mode tema saat ini
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // Fungsi untuk Beralih Tema
  void toggleTheme() {
    // Ubah nilai isDarkMode
    isDarkMode.value = !isDarkMode.value;

    // Ganti tema di aplikasi menggunakan GetX
    Get.changeThemeMode(themeMode);

    // Simpan preferensi baru ke penyimpanan lokal
    _saveThemeToBox(isDarkMode.value);
  }
}