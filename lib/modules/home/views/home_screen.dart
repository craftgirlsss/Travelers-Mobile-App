// lib/modules/home/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// PASTIKAN SUDAH ADA IMPORT INI
import 'package:icons_plus/icons_plus.dart';

import '../controllers/home_controller.dart';
import '../../../presentation/themes/app_theme.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: controller.pages[controller.selectedIndex.value],

      // Floating Action Button untuk Search
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('Fitur', 'Halaman Pencarian dibuka!', snackPosition: SnackPosition.BOTTOM);
        },
        backgroundColor: AppTheme.primaryColor,
        // Properti yang ditambahkan: Memastikan FAB berbentuk lingkaran
        shape: const CircleBorder(),
        // GANTI ICON SEARCH DENGAN ICONSAX
        child: const Icon(Iconsax.search_normal_outline, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(controller),
    ));
  }

  // Widget terpisah untuk BottomNavigationBar
  Widget _buildBottomNavigationBar(HomeController controller) {
    // Tentukan item mana yang aktif untuk memilih ikon yang benar
    final int selectedIndex = controller.selectedIndex.value;

    return BottomAppBar(
      // Hapus Container di sini. BottomAppBar langsung menjadi Child
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0, // Margin dibuat sedikit lebih besar (dari 5.0 ke 8.0) untuk memberi ruang lebih pada FAB
      color: Colors.white,

      // BottomNavigationBar langsung menjadi child dari BottomAppBar, HILANGKAN Container!
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: controller.changePage,
          // Background color diatur transparan agar BottomAppBar color (white) yang terlihat
          backgroundColor: Colors.transparent,
          elevation: 0, // Hapus bayangan tambahan dari BottomNavigationBar
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Get.theme.primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            // 1. HOME (Beranda)
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Iconsax.home_2_bold : Iconsax.home_2_outline),
              label: 'home_tab'.tr,
            ),

            // 2. BOOKING (Pemesanan/Ticket)
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1 ? Iconsax.ticket_star_bold : Iconsax.ticket_star_outline),
              label: 'booking_tab'.tr,
            ),

            // 3. Placeholder (Search)
            // Tambahkan padding vertikal agar rata dengan item lain
            const BottomNavigationBarItem(
              icon: Opacity(opacity: 0.0, child: Icon(Icons.search)),
              label: '',
            ),

            // 4. NOTIFIKASI
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3 ? Iconsax.notification_bold : Iconsax.notification_outline),
              label: 'Notifikasi'.tr,
            ),

            // 5. PENGATURAN (Profile/Settings)
            BottomNavigationBarItem(
              icon: Icon(selectedIndex == 4 ? Iconsax.setting_2_bold : Iconsax.setting_2_outline),
              label: 'Pengaturan'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
