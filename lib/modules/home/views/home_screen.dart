// lib/modules/home/views/home_screen.dart

// ... (imports)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../config/routes/app_routes.dart';
import '../../../presentation/themes/app_theme.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (kode Obx & Scaffold)
    return Obx(() => Scaffold(
      body: controller.pages[controller.selectedIndex.value],

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.TRIP_SEARCH);
        },
        backgroundColor: AppTheme.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Iconsax.search_normal_outline, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      // 💥 Tambahkan property `clipBehavior` di sini (opsional, tapi membantu)
      bottomNavigationBar: _buildBottomNavigationBar(controller),
    ));
  }

  // Widget terpisah untuk BottomNavigationBar
  Widget _buildBottomNavigationBar(HomeController controller) {
    final int selectedIndex = controller.selectedIndex.value;

    return BottomAppBar(
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,

      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: controller.changePage,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Get.theme.primaryColor,
        unselectedItemColor: Colors.grey,
        iconSize: 22.0,

        // 💥 Solusi 1: Atur Item Height ke 0 (biasanya tidak diperlukan, tapi coba)
        // selectedFontSize: 12,
        // unselectedFontSize: 12,

        // Solusi 2: Tambahkan padding vertikal negatif (HANYA JIKA SANGAT MEMAKSA)
        // padding: const EdgeInsets.only(bottom: -2.0), // Coba padding negatif

        items: [
          // ... (Item-item lainnya)
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
          const BottomNavigationBarItem(
            icon: Opacity(opacity: 0.0, child: Icon(Icons.search)),
            label: '',
          ),
          // 4. NOTIFIKASI
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 3 ? Iconsax.bookmark_2_bold : Iconsax.bookmark_2_outline),
            label: 'Favorite'.tr,
          ),
          // 5. PENGATURAN (Profile/Settings)
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 4 ? Iconsax.setting_2_bold : Iconsax.setting_2_outline),
            label: 'Pengaturan'.tr,
          ),
        ],
      ),
    );
  }
}