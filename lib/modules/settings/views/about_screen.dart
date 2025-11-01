import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../controllers/about_controller.dart';

class AboutScreen extends GetView<AboutController> {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
            'Tentang Aplikasi',
            style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: Icon(Bootstrap.arrow_left_short, color: Colors.black, size: 30),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Bagian 1: Fungsi Platform (Travelers) ---
            Image.asset('assets/images/vly.png', width: size.width / 2, height: 100.0),
            _buildSectionHeader('Platform VlyTrip', Bootstrap.airplane_engines),
            const SizedBox(height: 10),
            Text(
              "Travelers adalah platform pemesanan perjalanan terpadu yang didesain untuk mempermudah Anda menemukan, membandingkan, dan memesan paket trip domestik maupun internasional dari berbagai penyedia terpercaya di Indonesia. Kami menyediakan informasi detail, harga transparan, dan sistem reservasi yang aman, menjadikan perencanaan liburan Anda lebih efisien dan menyenangkan.",
              style: Get.textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            // --- Bagian 2: Tentang Perusahaan (KDI) ---
            Image.asset('assets/images/icon_perusahaan.png', width: size.width / 2, height: 100.0),
            _buildSectionHeader('Karya Developer Indonesia', Bootstrap.building),
            const SizedBox(height: 10),
            Text(
              "Aplikasi Travelers dikembangkan dan dikelola oleh **Karya Developer Indonesia (KDI)**. KDI adalah perusahaan teknologi yang berfokus pada solusi perangkat lunak yang inovatif dan andal. Kami berkomitmen untuk menciptakan ekosistem digital yang menghubungkan penyedia layanan dengan pengguna akhir secara efektif dan profesional.",
              style: Get.textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            // --- Bagian 3: Tombol Aksi ---
            _buildSectionHeader('Dukungan & Kerja Sama', Bootstrap.hand_thumbs_up),
            const SizedBox(height: 20),

            // Tombol Kerja Sama
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.launchUrlString(controller.partnershipUrl),
                icon: const Icon(Bootstrap.globe2, color: Colors.white),
                label: Text(
                  'Kerja Sama Bisnis',
                  style: Get.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Tombol Donasi
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.showDonationDetails,
                icon: const Icon(Bootstrap.heart_fill, color: Colors.red),
                label: Text(
                  'Dukung Kami (Donasi)',
                  style: Get.textTheme.titleMedium?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade400, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Footer Versi
            Center(
              child: Text(
                'Travelers v1.0.0 (Build 20251030)',
                style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Text(
      title,
      style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.black87),
    );
  }
}