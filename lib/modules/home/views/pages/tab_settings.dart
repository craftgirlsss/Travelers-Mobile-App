// lib/modules/home/views/pages/tab_settings.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:travelers/modules/settings/controllers/setting_controller.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../presentation/themes/app_theme.dart'; // Untuk primary color
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/home_controller.dart'; // Untuk Laporkan Bug

class SettingsTabView extends GetView<HomeController> {
  const SettingsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingController());
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // Header
          Text(
            'Settings',
            style: Get.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 32),
          ),
          const SizedBox(height: 30),

          // --- 1. Akun & Keamanan ---
          _buildSectionHeader('Akun & Keamanan'),
          _buildSettingsTile(
            title: 'Edit Profil',
            icon: Iconsax.user_edit_outline,
            onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
          _buildSettingsTile(
            title: 'Ganti Kata Sandi',
            icon: Iconsax.lock_1_outline,
            onTap: () => Get.snackbar('Navigasi', 'Membuka Ganti Password...'),
          ),
          const SizedBox(height: 20),

          // --- 2. Tampilan & Fungsionalitas ---
          _buildSectionHeader('Tampilan & Fungsionalitas'),
          const ThemeSwitchTile(),
          _buildSettingsTile(
            title: 'Ganti Bahasa',
            icon: Iconsax.language_square_outline,
            onTap: () => Get.snackbar('Navigasi', 'Membuka Pengaturan Bahasa...'),
          ),
          _buildSettingsTile(
            title: 'Voucher',
            icon: Iconsax.ticket_outline,
            onTap: () {
              Get.toNamed(Routes.MY_VOUCHERS);
              // Ganti ke tab Booking (asumsi index 1)
              // controller.changePage(1);
            },
            showTrailingIcon: true,
          ),
          const SizedBox(height: 20),

          // --- 3. Bantuan & Dukungan ---
          _buildSectionHeader('Bantuan & Dukungan'),
          _buildSettingsTile(
            title: 'Laporkan Bug',
            icon: Bootstrap.bug,
            onTap: _launchBugReport,
          ),
          _buildSettingsTile(
            title: 'Tentang Aplikasi',
            icon: Bootstrap.info_circle,
            onTap: () => Get.toNamed(Routes.ABOUT),
          ),
          const SizedBox(height: 40),

          // --- 4. Log Out ---
          _buildLogoutButton(controller),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Widget Pembantu (Helper Widgets) ---

  // Header Section
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title,
        style: Get.textTheme.titleSmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  // General Settings Tile (dengan Icon dan Arrow)
  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showTrailingIcon = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Get.theme.shadowColor.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: Get.textTheme.titleMedium),
        trailing: showTrailingIcon ? const Icon(Iconsax.arrow_right_3_outline, size: 18) : null,
        onTap: onTap,
      ),
    );
  }

  // Theme Switch Tile (Khusus untuk Dark/Light Mode)
  Widget _buildThemeSwitchTile(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.isDarkMode;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            isDarkMode ? Iconsax.sun_1_bold : Iconsax.moon_outline,
            color: AppTheme.primaryColor,
          ),
          title: Text('Tema Gelap/Terang', style: Get.textTheme.titleMedium),
          trailing: Switch.adaptive(
            value: isDarkMode,
            onChanged: (val) {
              // Mengganti tema menggunakan GetX
              Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
            activeColor: AppTheme.primaryColor,
          ),
          onTap: () {
            // Tap pada tile juga bisa mengganti tema
            Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
          },
        ),
      );
    });
  }

  // Log Out Button
  Widget _buildLogoutButton(SettingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OutlinedButton.icon(
        icon: const Icon(Iconsax.logout_outline, size: 20),
        label: Text('Log Out', style: Get.textTheme.titleMedium),
        onPressed: () => Get.defaultDialog(
          title: "Konfirmasi Log Out",
          middleText: "Anda yakin ingin keluar dari akun ini?",
          textConfirm: "Ya, Keluar",
          textCancel: "Batal",
          confirmTextColor: Colors.white,
          cancelTextColor: AppTheme.primaryColor,
          buttonColor: AppTheme.primaryColor,
          onConfirm: () => controller.performLogout()
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade600, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Fungsi untuk meluncurkan email/link bug report
  void _launchBugReport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@travelers.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Laporan Bug dari Aplikasi Mobile',
        'body': 'Jelaskan bug yang Anda temukan di sini...'
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka aplikasi email.');
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

// Di bagian bawah file tab_settings.dart

class ThemeSwitchTile extends StatelessWidget {
  const ThemeSwitchTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan Obx di sini
      final isDarkMode = Get.isDarkMode;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            isDarkMode ? Iconsax.sun_1_bold : Iconsax.moon_outline,
            color: AppTheme.primaryColor,
          ),
          title: Text('Tema Gelap/Terang', style: Get.textTheme.titleMedium),
          trailing: Switch.adaptive(
            value: isDarkMode,
            onChanged: (val) {
              Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
            activeColor: AppTheme.primaryColor,
          ),
          onTap: () {
            Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
          },
        ),
      );
  }
}