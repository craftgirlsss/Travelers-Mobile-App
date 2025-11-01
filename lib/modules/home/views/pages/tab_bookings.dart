// lib/modules/home/views/pages/tab_booking.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../data/models/booking_model.dart';
import '../../../booking/controllers/booking_controller.dart';
import '../../../../presentation/themes/app_theme.dart';
import 'package:intl/intl.dart';

class BookingTabView extends GetView<BookingController> {
  const BookingTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Inisialisasi controller jika belum melalui HomeBinding
    if (Get.context != null && Get.isRegistered<BookingController>() == false) {
      Get.put(BookingController());
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: size.width / 1.9,
        leading: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Text(
            'Pemesanan',
            style: Get.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 32),
          ),
        ),
        toolbarHeight: 70,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          indicatorAnimation: TabIndicatorAnimation.elastic,
          controller: controller.tabController,
          dividerColor: Theme.of(context).dividerColor.withOpacity(0.2),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: controller.tabs.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: controller.tabController,
          children: [
            _buildBookingList(controller.paidBookings, 'paid'),
            _buildBookingList(controller.unpaidBookings, 'unpaid'),
            _buildBookingList(controller.overdueBookings, 'overdue'),
          ],
        );
      }),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBookingList(List<BookingModel> bookings, String status) {
    if (bookings.isEmpty) {
      String message;
      if (status == 'paid') {
        message = 'Belum ada pemesanan yang dibayar.';
      } else if (status == 'unpaid') {
        message = 'Tidak ada tagihan yang tertunda saat ini.';
      } else {
        message = 'Tidak ada pemesanan yang kadaluarsa.';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.receipt_item_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 15),
              Text(message, textAlign: TextAlign.center, style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(context, bookings[index], status);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking, String status) {
    // Format tanggal dan harga
    final dateFormat = DateFormat('dd MMM yyyy');
    final priceFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    Color getStatusColor() {
      switch (status) {
        case 'paid': return Colors.green.shade600;
        case 'overdue': return Colors.red.shade600;
        case 'unpaid': return Colors.orange.shade600;
        default: return Colors.grey.shade600;
      }
    }

    String getStatusLabel() {
      switch (status) {
        case 'paid': return 'Lunas';
        case 'overdue': return 'Kadaluarsa';
        case 'unpaid': return 'Menunggu Pembayaran';
        default: return booking.status.capitalizeFirst ?? 'Unknown';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Get.theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status & Tanggal Pemesanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getStatusLabel(),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Tgl. Pesan: ${dateFormat.format(DateTime.parse(booking.bookingDate))}',
                style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          Divider(height: 25, color: Theme.of(context).dividerColor.withOpacity(0.1),),

          // Detail Trip
          Text(
            booking.tripTitle,
            style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Provider & Lokasi
          Row(
            children: [
              const Icon(Iconsax.user_tag_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(booking.providerName, style: Get.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Iconsax.location_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Expanded(child: Text(booking.location, style: Get.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 15),

          // Harga, Jumlah Orang, Tanggal Trip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Jumlah Orang
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Peserta', style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  Text('${booking.numOfPeople} Orang', style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              // Tanggal Trip
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tgl. Mulai', style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  Text(dateFormat.format(DateTime.parse(booking.startDate)), style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              // Total Harga
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total', style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  Text(priceFormat.format(booking.totalPrice), style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ],
          ),

          // Tombol Aksi (hanya untuk unpaid/overdue)
          if (status != 'paid') ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.snackbar('Navigasi', 'Membuka Detail Pembayaran ${booking.bookingUuid}...'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: status == 'overdue' ? Colors.red.shade600 : AppTheme.primaryColor,
                  side: BorderSide(color: status == 'overdue' ? Colors.red.shade300 : AppTheme.primaryColor, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(status == 'overdue' ? 'Lihat Detail' : 'Lanjut Bayar'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}