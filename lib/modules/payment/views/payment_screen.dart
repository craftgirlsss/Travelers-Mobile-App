import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travelers/data/models/payment_method_model.dart';
import 'package:travelers/modules/payment/controllers/payment_controller.dart';
import 'package:travelers/presentation/themes/app_theme.dart';
import 'package:travelers/presentation/widgets/custom_shimmer.dart';

// Catatan: Pastikan CustomShimmer sudah ada di lib/presentation/widgets/custom_shimmer.dart

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller jika belum
    if (Get.arguments == null || Get.arguments['tripUuid'] == null || Get.arguments['bookingUuid'] == null) {
      return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Data booking tidak valid.')));
    }
    Get.put(PaymentController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pembayaran'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        final details = controller.paymentDetails.value;
        if (details == null) {
          return const Center(child: Text('Detail tagihan tidak dapat dimuat.'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Ringkasan Tagihan ---
                    _buildPaymentSummary(details.totalPrice, details.tripTitle),
                    const SizedBox(height: 20),

                    // --- 2. Pilihan Metode Pembayaran ---
                    Text('Pilih Metode Pembayaran', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (controller.paymentMethods.isEmpty)
                      const Center(child: Text('Tidak ada metode pembayaran dari provider.')),
                    ...controller.paymentMethods.map((method) => _buildPaymentMethodCard(method, controller)).toList(),

                    const SizedBox(height: 20),

                    // --- 3. Formulir Konfirmasi Pembayaran ---
                    Text('Konfirmasi Bukti Pembayaran', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Input Catatan Opsional
                    TextField(
                      controller: controller.noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan/Deskripsi (Opsional)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Unggah Bukti
                    _buildProofUploadSection(context, controller),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // --- Bottom Button ---
            _buildSubmitButton(controller),
          ],
        );
      }),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPaymentSummary(double totalAmount, String tripTitle) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tripTitle, style: Get.textTheme.titleMedium),
          const SizedBox(height: 5),
          Text('Total yang Harus Dibayar:', style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          Text(
            currencyFormatter.format(totalAmount),
            style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Bootstrap.clock, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              // TODO: Ambil Due Date yang sebenarnya dari API jika ada. Saat ini hanya placeholder.
              Text('Batas Waktu Pembayaran: 24 Jam', style: Get.textTheme.bodyMedium?.copyWith(color: Colors.red.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel method, PaymentController controller) {
    final isSelected = controller.selectedMethod.value?.id == method.id;
    return GestureDetector(
      onTap: () => controller.selectMethod(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${method.bankName} (${method.methodType})', style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(method.accountNumber, style: Get.textTheme.bodyLarge),
                  Text('a/n ${method.accountName}', style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
                ],
              ),
            ),
            if (method.methodType == 'QRIS' && method.qrisImageUrl != null)
              GestureDetector(
                onTap: () => Get.defaultDialog(
                  title: "QRIS Code",
                  // ⚠️ PERLU URL BASE API! Ganti "YOUR_BASE_URL" dengan URL API Anda.
                  content: Image.network("YOUR_BASE_URL/${method.qrisImageUrl}", fit: BoxFit.cover),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: const Icon(Bootstrap.qr_code, color: AppTheme.primaryColor, size: 30),
                ),
              ),
            Icon(
              isSelected ? Bootstrap.check_circle_fill : Bootstrap.circle,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofUploadSection(BuildContext context, PaymentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview Gambar atau Placeholder Unggah
        controller.proofImage.value == null
            ? Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.gallery_add_outline, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              Text('Belum ada bukti transfer', style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey)),
            ],
          ),
        )
            : Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(File(controller.proofImage.value!.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tombol Aksi Unggah/Ganti Gambar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showImageSourceDialog(context, controller),
            icon: const Icon(Bootstrap.upload, size: 20),
            label: Text(controller.proofImage.value == null ? 'Unggah Bukti Transfer' : 'Ganti Bukti Transfer'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppTheme.primaryColor),
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // Dialog untuk memilih sumber gambar (Camera/Gallery)
  void _showImageSourceDialog(BuildContext context, PaymentController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.camera_outline, color: AppTheme.primaryColor),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Get.back();
                controller.pickProofImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery_outline, color: AppTheme.primaryColor),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Get.back();
                controller.pickProofImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(PaymentController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.submitPaymentProof,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Obx(() => controller.isLoading.value
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
            'Konfirmasi Pembayaran',
            style: Get.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomShimmer(height: 120, borderRadius: 12),
          const SizedBox(height: 20),
          CustomShimmer(height: 20, width: 200),
          const SizedBox(height: 10),
          const CustomShimmer(height: 80, borderRadius: 12),
          const SizedBox(height: 10),
          const CustomShimmer(height: 80, borderRadius: 12),
          const SizedBox(height: 20),
          CustomShimmer(height: 20, width: 250),
          const SizedBox(height: 10),
          const CustomShimmer(height: 150, borderRadius: 10),
          const SizedBox(height: 10),
          const CustomShimmer(height: 48, borderRadius: 12),
        ],
      ),
    );
  }
}