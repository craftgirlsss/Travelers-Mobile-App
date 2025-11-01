import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {

  // URL untuk Kerja Sama
  final String partnershipUrl = 'https://karyadeveloperindonesia.com';

  // Fungsi untuk membuka URL
  Future<void> launchUrlString(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Tampilkan error jika gagal membuka link
      Get.snackbar(
        'Gagal Membuka Link',
        'Tidak dapat membuka $urlString',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Fungsi untuk menyalin nomor rekening (Opsional)
  void copyToClipboard(String text, String label) {
    // Implementasi penyalinan (membutuhkan package flutter/services)
    // import 'package:flutter/services.dart';
    // Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Berhasil Disalin',
      '$label: $text telah disalin ke clipboard.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Fungsi untuk menampilkan detail donasi
  void showDonationDetails() {
    Get.defaultDialog(
      title: "Pilihan Donasi 💖",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dukungan Anda sangat berarti bagi kami!", style: Get.textTheme.titleSmall),
          const SizedBox(height: 15),

          // ShopeePay
          _buildDonationItem("ShopeePay", "0881036480285", "Nomor ShopeePay"),
          const Divider(),

          // BCA
          _buildDonationItem("Bank BCA", "8725164421", "Rekening BCA a/n Saputra Budianto"),
        ],
      ),
      textConfirm: "Tutup",
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.primaryColor,
      onConfirm: () => Get.back(),
    );
  }

  Widget _buildDonationItem(String title, String number, String copyLabel) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(number, style: Get.textTheme.titleMedium?.copyWith(color: Get.theme.primaryColor)),
      trailing: IconButton(
        icon: const Icon(Bootstrap.clipboard_check, size: 20),
        onPressed: () => copyToClipboard(number, copyLabel),
      ),
    );
  }
}