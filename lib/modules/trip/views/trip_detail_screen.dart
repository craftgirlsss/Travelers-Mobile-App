import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../../data/models/trip_detail_model.dart';
import '../../../data/models/booking_status_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../controllers/trip_detail_controller.dart';
import '../../../presentation/themes/app_theme.dart';

class TripDetailScreen extends GetView<TripDetailController> {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final trip = controller.tripDetail.value;
      if (trip == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Data trip tidak ditemukan.')),
        );
      }

      final mainImage = trip.images.firstWhereOrNull((img) => img.isMain == 1)?.imageUrl ?? trip.images.firstOrNull?.imageUrl;

      return Scaffold(
        extendBodyBehindAppBar: true,
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchTripDetails(controller.tripUuid);
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Gambar
                _imageDestination(
                    size,
                    companyProviderImageURL: trip.provider.companyLogoPath,
                    imageURL: mainImage,
                    location: trip.location,
                    title: trip.title
                ),

                // Tabs (Details/Review)
                _buildTabs(controller),

                // Konten yang Beralih Berdasarkan Tab Aktif
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildTabContent(controller, trip), // 💥 DIPERBARUI DI BAWAH
                ),
                const SizedBox(height: 30), // Ruang di atas bottom bar
              ],
            ),
          ),
        ),
        // BOTTOM NAVIGATION BAR DINAMIS
        bottomNavigationBar: Obx(
          () => _buildBottomActionButtons(
            trip.price,
            trip.bookingStatus,
            onBookPressed: () => _showBookingDialog(context),
            onPayNowPressed: controller.viewPaymentDetail,
            onCancelBookPressed: controller.cancelBook,
            onViewDetailPressed: controller.viewPaymentDetail,
            isBookingLoading: controller.isBookingLoading.value,
            bookedUuid: controller.bookedUuid.value,
          ),
        ),
      );
    });
  }

  // 💥 FUNGSI DIALOG BARU
  void _showBookingDialog(BuildContext context) {
    // Pastikan controller telah diinisialisasi
    if (controller.tripDetail.value == null) return;
    final tripPrice = controller.tripDetail.value!.price;

    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Booking'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Harga per orang: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(tripPrice)}'),
            const SizedBox(height: 15),

            // --- Pilih Jumlah Orang ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jumlah Orang:'),
                Row(
                  children: [
                    _buildPeopleButton(Icons.remove, () {
                      if (controller.numOfPeople.value > 1) {
                        controller.numOfPeople.value--;
                        controller.calculatedPrice.value = controller.calculateTotalPrice(controller.numOfPeople.value);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        controller.numOfPeople.value.toString(),
                        style: Get.textTheme.titleLarge,
                      ),
                    ),
                    _buildPeopleButton(Icons.add, () {
                      controller.numOfPeople.value++;
                      controller.calculatedPrice.value = controller.calculateTotalPrice(controller.numOfPeople.value);
                    }),
                  ],
                ),
              ],
            ),
            const Divider(height: 25),

            // --- Total Harga ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Harga:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(controller.calculatedPrice.value),
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Tutup dialog
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isBookingLoading.value ? null : () {
              controller.performBooking(controller.numOfPeople.value);
            },
            child: controller.isBookingLoading.value
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
            )
                : const Text('Book Now'),
          )),
        ],
      ),
    );
  }

// 💥 Helper untuk tombol + / -
  Widget _buildPeopleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppTheme.primaryColor),
        onPressed: onPressed,
      ),
    );
  }

  // lib/modules/trip/views/trip_detail_screen.dart (Revisi _buildBottomActionButtons)

  Widget _buildBottomActionButtons(
      int price,
      BookingStatusModel? bookingStatus, // Menggunakan model status
          {
        required VoidCallback onBookPressed,
        required VoidCallback onPayNowPressed,
        required VoidCallback onCancelBookPressed,
        required VoidCallback onViewDetailPressed,
        required bool isBookingLoading,
        required String? bookedUuid, // Nilai ini datang dari controller.bookedUuid.value
      }
      ) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // 💥 Kuncinya: bookedUuid sudah berupa nilai (bukan Rx) saat masuk ke fungsi ini,
    // tapi fungsi ini dipanggil di dalam Obx di build(), jadi update state seharusnya sudah terjadi.
    // Masalahnya kemungkinan besar adalah layout harga yang kaku.

    // Logika penentuan status (tetap sama)
    bool tripIsAlreadyBooked = bookingStatus?.booked ?? false || bookedUuid != null;
    bool tripIsPaid = bookingStatus?.paid ?? false;

    Widget actionWidget;

    if (!tripIsAlreadyBooked) {
      // Case 1: Belum dibooking -> Tampilkan Tombol "Book Now"
      actionWidget = _buildActionButton(
        text: "Book Now",
        onPressed: onBookPressed,
        isLoading: isBookingLoading,
        isDisabled: isBookingLoading,
      );
    } else if (tripIsAlreadyBooked && !tripIsPaid) {
      // Case 2: Sudah dibooking tapi belum bayar -> Cancel & Pay Now
      actionWidget = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 💥 PERBAIKAN: Bungkus TextButton dengan Flexible
          Flexible(
            child: TextButton(
              onPressed: onCancelBookPressed,
              // Pastikan tidak ada wrapping di sini agar teks tetap satu baris
              child: Text(
                'Cancel Book',
                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                maxLines: 1, // Pastikan hanya satu baris
                overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika teks kepanjangan
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 💥 PERBAIKAN: Bungkus Tombol Pay Now dengan Expanded
          Expanded(
            child: _buildActionButton(
              text: "Pay Now",
              onPressed: onPayNowPressed,
              isLoading: false,
              isDisabled: false,
            ),
          ),
        ],
      );
    } else { // isBooked && isPaid
      // Case 3: Sudah dibayar -> Detail Payment
      actionWidget = _buildActionButton(
        text: "Detail Payment",
        onPressed: onViewDetailPressed,
        isLoading: false,
        isDisabled: false,
      );
    }

    // Container Utama (Harga dan Aksi)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, -2)
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 💥 PERBAIKAN 1: Bungkus Kolom Harga dengan Flexible untuk mengatasi overflow
          Flexible(
            flex: 2, // Beri fleksibilitas lebih kecil (misalnya 2)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total Price", style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                Text(
                  currencyFormatter.format(price),
                  style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.black),
                  overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika masih terlalu panjang
                ),
              ],
            ),
          ),

          const SizedBox(width: 10), // Tambahkan sedikit jarak

          // 💥 PERBAIKAN 2: Bungkus Aksi Dinamis dengan Flexible/Expanded
          Flexible(
            flex: 3, // Beri fleksibilitas lebih besar (misalnya 3) agar tombol aksi mendapat ruang
            child: actionWidget,
          ),
        ],
      ),
    );
  }

  // Helper untuk Tombol Aksi
  Widget _buildActionButton({required String text, required VoidCallback onPressed,required bool isLoading, required bool isDisabled}) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey : AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: isLoading
        ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
        : Text(
          text,
          style: Get.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        textAlign: TextAlign.center,
        ),
    );
  }


  // --------------------------------------------------------------------------
  // --- WIDGETS LAINNYA (DARI KODE SEBELUMNYA) ---
  // --------------------------------------------------------------------------

  Widget _buildTabContent(TripDetailController controller, TripDetailModel trip) {
    if (controller.activeTab.value == 'Details') {

      final guide = trip.tourGuide?.mainGuide;
      final accommodation = trip.accommodation;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Statistics
          _buildStatisticsRow(trip),
          const SizedBox(height: 30),

          // Description
          Text(
            'Description',
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            trip.description,
            style: Get.textTheme.bodyMedium?.copyWith(height: 1.5, color: Colors.grey[700]),
          ),
          const SizedBox(height: 30),

          // Group Members
          _buildGroupMembersWidget(),
          const SizedBox(height: 30),

          // Detail Trip Tambahan
          Text(
            'Informasi Perjalanan',
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Informasi Dasar
          _buildTripInfoRow(Iconsax.calendar_tick_outline, "Tanggal", trip.startDate),
          _buildTripInfoRow(Iconsax.clock_outline, "Waktu", "${trip.departureTime.substring(0, 5)} - ${trip.returnTime.substring(0, 5)}"),
          _buildTripInfoRow(Iconsax.user_tag_outline, "Penyedia", trip.provider.companyName),

          const SizedBox(height: 15),

          // 💥 Poin Kumpul (Gathering Point) yang bisa diklik
          _buildGatheringPoint(trip.gatheringPointName, trip.gatheringPointUrl),
          const SizedBox(height: 20),

          if (accommodation?.hasAccommodation == true)
            _buildAccommodationInfo(accommodation!.details),

          // 💥 Pemandu Wisata (Hanya tampil jika ada)
          if (guide != null)
            _buildGuideInfo(guide.profilePhotoPath, guide.name, guide.specialization, guide.phoneNumber),

          // 💥 BARU: Informasi Kendaraan (Hanya tampil jika ada)
          if (trip.vehicle != null)
            _buildVehicleInfo(trip.vehicle!),

          const SizedBox(height: 30),
        ],
      );
    } else {
      return _buildReviewContent();
    }
  }

  Widget _buildVehicleInfo(VehicleModel vehicle) {
    const String baseUrl = 'https://provider-travelers.karyadeveloperindonesia.com/';
    String? fullImageUrl;
    if(vehicle.photoPath != null){
      fullImageUrl = baseUrl + vehicle.photoPath!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transportasi',
          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Kendaraan
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fullImageUrl ?? '',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(Iconsax.car_outline, size: 50, color: Colors.grey.shade500),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Detail Teks Kendaraan
              Text(
                vehicle.name ?? 'Unknown Vehicle Name',
                style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  // 💥 BLOK 1: Kapasitas (Menggunakan Flexible)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Penting agar Row ini hanya mengambil ruang yang dibutuhkan
                      children: [
                        Icon(Iconsax.people_outline, size: 18, color: AppTheme.primaryColor),
                        const SizedBox(width: 5),
                        Flexible( // Bungkus Text dengan Flexible agar bisa dipotong
                          child: Text(
                            'Kapasitas: ${vehicle.capacity ?? 0} Orang',
                            style: Get.textTheme.bodyMedium,
                            maxLines: 1, // Pastikan hanya satu baris
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 15), // Pemisah antara Kapasitas dan Tipe

                  // 💥 BLOK 2: Tipe (Menggunakan Flexible)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Penting agar Row ini hanya mengambil ruang yang dibutuhkan
                      children: [
                        Icon(Iconsax.tag_outline, size: 18, color: AppTheme.primaryColor),
                        const SizedBox(width: 5),
                        Flexible( // Bungkus Text dengan Flexible agar bisa dipotong
                          child: Text(
                            'Tipe: ${vehicle.type != null ? vehicle.type!.capitalizeFirst : 'Unknown Vehicle Type'}',
                            style: Get.textTheme.bodyMedium,
                            maxLines: 1, // Pastikan hanya satu baris
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccommodationInfo(String? details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akomodasi',
          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoCard(
          icon: Iconsax.home_trend_up_outline,
          title: 'Termasuk Penginapan',
          subtitle: details ?? 'Detail akomodasi tidak tersedia',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppTheme.primaryColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildGuideInfo(String photoPath, String name, String specialization, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pemandu Utama',
          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoCard(
          icon: Iconsax.user_octagon_outline,
          title: name,
          subtitle: specialization,
          trailing: IconButton(
            icon: Icon(Iconsax.call_calling_outline, color: Colors.green),
            onPressed: () => controller.launchURL('tel:$phone'), // Telepon Pemandu
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGatheringPoint(String name, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titik Kumpul',
          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell( // Menggunakan InkWell agar bisa diklik
          onTap: () => controller.launchURL(url),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Iconsax.map_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Get.textTheme.bodyLarge),
                      Text(
                        'Tap untuk melihat di Google Maps',
                        style: Get.textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3_outline, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(value, style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent() {
    final List<Map<String, dynamic>> reviews = [
      {'name': 'Risa Putri', 'rating': 5.0, 'comment': 'Trip yang sangat mengesankan!'},
      {'name': 'Aldi Wijaya', 'rating': 4.5, 'comment': 'Akomodasi bagus, tapi jadwal sedikit padat.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews (${reviews.length})',
          style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        ...reviews.map((review) => _buildReviewTile(
          review['name']!,
          review['rating'] as double,
          review['comment']!,
        )).toList(),
      ],
    );
  }

  Widget _buildReviewTile(String name, double rating, String comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(name[0], style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.floor() ? Icons.star :
                          (index < rating ? Icons.star_half : Icons.star_border),
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 50),
            child: Text(
              comment,
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupMembersWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 65,
                  child: Stack(
                    children: List.generate(3, (index) => Positioned(
                      left: index * 15.0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    )),
                  ),
                ),
                const Text("20+ Trip Members", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.arrow_right_2_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(TripDetailController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        children: [
          _buildPillTab(controller, 'Details'),
          _buildPillTab(controller, 'Review'),
        ],
      ),
    );
  }

  Widget _buildPillTab(TripDetailController controller, String tabName) {
    return Obx(() {
      final bool isSelected = controller.activeTab.value == tabName;

      return GestureDetector(
        onTap: () => controller.changeTab(tabName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tabName,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Widget _imageDestination(Size size, {required String? companyProviderImageURL, required String? imageURL, required String? location, required String? title}){
    return Container(
      width: double.infinity,
      height: size.height / 2.5,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
        image: DecorationImage(
          image: NetworkImage(imageURL != null ? 'https://provider-travelers.karyadeveloperindonesia.com/$imageURL' : ''), // Fallback image
          fit: BoxFit.cover
        )
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 35.0),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(9.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: const Icon(Iconsax.arrow_left_outline),
                  ),
                ),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                      image: DecorationImage(
                        image: NetworkImage("https://provider-travelers.karyadeveloperindonesia.com/$companyProviderImageURL"),
                        fit: BoxFit.cover,
                      )
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 20.0,
              left: 0.0,
              right: 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(title ?? '', style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 15, color: Colors.white),
                              const SizedBox(width: 1),
                              Flexible(
                                child: Text(
                                  location ?? '-',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(TripDetailModel trip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(Iconsax.global_outline, "${trip.distanceKm.toStringAsFixed(1)} KM", "Distance"),
        _buildStatItem(Iconsax.star_1_outline, "${trip.rating.toStringAsFixed(1)}", "Ratings"),
        _buildStatItem(Iconsax.cloud_sunny_outline, "${trip.tempC.toStringAsFixed(1)}°C", "Temp"),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 5),
        Text(value, style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}