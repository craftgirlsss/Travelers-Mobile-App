import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart'; // Menggunakan Iconsax dan Bootstrap
import '../../../config/routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../../presentation/themes/app_theme.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppTheme.primaryColor;

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,

      // 💥 FAB DIHILANGKAN
      // floatingActionButton: ...
      // floatingActionButtonLocation: ...

      // Konten utama: Halaman yang dipilih
      body: controller.pages[controller.selectedIndex.value],

      // 💥 Menggunakan NavigationBar standar (Material 3)
      bottomNavigationBar: _buildNavigationBar(controller, primaryColor),
    ));
  }

  // --- Widget Builders ---

  // Widget untuk Bottom Navigation Bar (menggunakan NavigationBar M3)
  Widget _buildNavigationBar(HomeController controller, Color primaryColor) {
    final int selectedIndex = controller.selectedIndex.value;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        // Logika tambahan: Jika Tab Search (Index 2) diklik, lakukan navigasi.
        if (index == 2) {
          Get.toNamed(Routes.TRIP_SEARCH);
        } else {
          controller.changePage(index);
        }
      },
      backgroundColor: Colors.white,
      elevation: 5,
      height: 70, // Memberikan tinggi eksplisit untuk stabilitas
      indicatorColor: primaryColor.withOpacity(0.15),

      destinations: <Widget>[
        // 1. Home (Index 0)
        NavigationDestination(
          icon: Icon(selectedIndex == 0 ? Iconsax.home_2_bold : Iconsax.home_2_outline, color: selectedIndex == 0 ? primaryColor : Colors.grey.shade600),
          label: 'home_tab'.tr,
        ),

        // 2. Booking (Index 1)
        NavigationDestination(
          icon: Icon(selectedIndex == 1 ? Iconsax.ticket_star_bold : Iconsax.ticket_star_outline, color: selectedIndex == 1 ? primaryColor : Colors.grey.shade600),
          label: 'booking_tab'.tr,
        ),

        // 3. 💥 SEARCH (Index 2 - Posisi Tengah)
        NavigationDestination(
          // Gunakan warna primer saat di-klik (meski hanya navigasi)
          icon: Icon(Iconsax.search_normal_outline, color: primaryColor, size: 28),
          label: 'Cari',
        ),

        // 4. Favorite (Index 3)
        NavigationDestination(
          icon: Icon(selectedIndex == 3 ? Iconsax.bookmark_2_bold : Iconsax.bookmark_2_outline, color: selectedIndex == 3 ? primaryColor : Colors.grey.shade600),
          label: 'Favorite'.tr,
        ),

        // 5. Pengaturan (Index 4)
        NavigationDestination(
          icon: Icon(selectedIndex == 4 ? Iconsax.setting_2_bold : Iconsax.setting_2_outline, color: selectedIndex == 4 ? primaryColor : Colors.grey.shade600),
          label: 'Pengaturan'.tr,
        ),
      ],
    );
  }
}