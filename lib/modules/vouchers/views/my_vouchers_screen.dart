// lib/modules/vouchers/views/my_vouchers_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../../presentation/themes/app_theme.dart';
import '../controllers/my_vouchers_controller.dart';
import '../../../data/models/claimed_voucher_model.dart';

class MyVouchersScreen extends GetView<MyVouchersController> {
  const MyVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher Saya'),
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: controller.tabController,
          tabs: controller.tabs,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Theme.of(context).dividerColor.withOpacity(0.2),
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: controller.tabController,
          children: [
            // Tab 1: Belum Digunakan
            _buildVoucherList(controller.unusedVouchers),
            // Tab 2: Sudah Digunakan / Kadaluarsa
            _buildVoucherList(controller.usedOrExpiredVouchers),
          ],
        );
      }),
    );
  }

  Widget _buildVoucherList(List<ClaimedVoucherModel> vouchers) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.ticket_outline, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text('Tidak ada voucher di sini.', style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        return _buildVoucherCard(context, vouchers[index]);
      },
    );
  }

  Widget _buildVoucherCard(BuildContext context, ClaimedVoucherModel voucher) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    final String valueText = voucher.type == 'percentage'
        ? '${voucher.value.toInt()}% OFF'
        : currencyFormatter.format(voucher.value);

    final bool isUsed = voucher.claimStatus == 'used';
    final bool isExpired = voucher.isExpired;
    final bool isDisabled = isUsed || isExpired;

    // Tentukan warna berdasarkan status
    Color primaryColor = isDisabled ? Colors.grey : AppTheme.primaryColor;

    // Desain linear dan bersih
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: isDisabled
            ? null
            : [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // 1. Bagian Kiri: Value dan Kode (Desain Tegas)
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 10),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  valueText,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  voucher.code,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. Bagian Kanan: Detail & Status
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Voucher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUsed ? 'SUDAH DIPAKAI' : isExpired ? 'KADALUARSA' : 'SIAP DIGUNAKAN',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: isUsed ? Colors.red.shade600 : isExpired ? Colors.orange.shade600 : Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Iconsax.arrow_right_3_outline, size: 18, color: primaryColor),
                    ],
                  ),
                  Divider(height: 15, color: Theme.of(context).dividerColor.withOpacity(0.2)),

                  // Info Kedaluwarsa
                  Row(
                    children: [
                      Icon(Iconsax.calendar_tick_outline, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Berlaku hingga:',
                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd MMM yyyy').format(voucher.validUntil),
                        style: Get.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Info Waktu Klaim
                  Row(
                    children: [
                      Icon(Iconsax.timer_outline, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Diklaim pada:',
                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        voucher.claimedAt != null ? DateFormat('dd/MM/yy').format(DateTime.parse(voucher.claimedAt!)) : 'N/A',
                        style: Get.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}