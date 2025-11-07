import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../presentation/themes/app_theme.dart';
import '../controllers/payment_detail_controller.dart';

class PaymentDetailScreen extends GetView<PaymentDetailController> {
  const PaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
        final dateFormatter = DateFormat('dd MMMM yyyy, HH:mm');

        // final detail = controller.paymentDetail.value; // Jika menggunakan API
        // if (detail == null) { ... return error state ... }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Status dan Notifikasi ---
              _buildInfoBox(
                icon: Iconsax.timer_1_outline,
                title: 'Menunggu Pembayaran',
                subtitle: 'Selesaikan pembayaran sebelum ${dateFormatter.format(controller.dueDate.value)}',
                color: Colors.orange.shade700,
                bgColor: Colors.orange.shade50,
              ),
              const SizedBox(height: 20),

              // --- Detail Tagihan ---
              Text('Detail Tagihan', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildSummaryRow('Total Tagihan', currencyFormatter.format(controller.totalPrice.value), isTotal: true),
              _buildSummaryRow('Booking ID', controller.bookingUuid.substring(0, 15) + '...', isTotal: false),
              // Tambahkan rincian lain (mis: Harga Trip x Jumlah Org, Biaya Admin)
              const SizedBox(height: 30),

              // --- Metode Pembayaran ---
              Text('Metode Pembayaran', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildPaymentMethodCard(
                method: controller.paymentMethod.value,
                vaNumber: controller.virtualAccountNumber.value,
                onCopy: controller.copyVaNumber,
                onViewInstructions: controller.viewPaymentInstructions,
              ),
              const SizedBox(height: 50),

              // --- Tombol Aksi (Opsional: Bayar Ulang / Bantuan) ---
              ElevatedButton(
                onPressed: controller.viewPaymentInstructions,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lihat Instruksi Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoBox({required IconData icon, required String title, required String subtitle, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Get.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
                Text(subtitle, style: Get.textTheme.bodyMedium?.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : Get.textTheme.bodyLarge),
          Text(value, style: isTotal ? Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.primaryColor) : Get.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({required String method, required String vaNumber, required VoidCallback onCopy, required VoidCallback onViewInstructions}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metode: $method', style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 25),
            Text('Virtual Account Number', style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vaNumber, style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                IconButton(
                  icon: Icon(Iconsax.copy_outline, color: AppTheme.primaryColor),
                  onPressed: onCopy,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}