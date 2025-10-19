// lib/modules/trip/views/trip_detail_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../data/models/trip_detail_model.dart';
import '../controllers/trip_detail_controller.dart';
import '../../../presentation/themes/app_theme.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang

class TripDetailScreen extends GetView<TripDetailController> {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          appBar: AppBar(title: const Text('Loading...')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final trip = controller.tripDetail.value;
      if (trip == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Data trip tidak ditemukan.')),
        );
      }

      // Pastikan ada import: import 'package:travelers/config/routes/app_routes.dart';
      // Pastikan ada import: import 'package:icons_plus/icons_plus.dart'; (AntDesign.arrow_left_outline)

      return Scaffold(
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Gambar (Stack, sudah benar)
              _imageDestination(
                  size,
                  companyProviderImageURL: trip.provider.companyLogoPath,
                  imageURL: trip.images.firstWhereOrNull((img) => img.isMain)?.imageUrl ?? trip.images.firstOrNull?.imageUrl,
                  location: trip.location,
                  title: trip.title
              ),

              // Tabs (Details/Review)
              _buildTabs(controller),

              // Konten yang Beralih Berdasarkan Tab Aktif
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildTabContent(controller, trip),
              ),
              const SizedBox(height: 30), // Ruang di atas bottom bar
            ],
          ),
        ),
        bottomNavigationBar: _buildBookNowContent(trip.price, controller.bookNow),
      );
    });
  }

  Widget _buildBookNowContent(int price, VoidCallback onPressed) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      // Container ini sekarang tidak perlu dekorasi shadow/positioning,
      // cukup untuk menampung Row.
      color: Get.theme.scaffoldBackgroundColor, // Atau warna latar belakang yang diinginkan
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Penting agar Column tidak memakan ruang berlebihan
            children: [
              Text("Total Price", style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(
                currencyFormatter.format(price),
                style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Book Now",
              style: Get.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET UNTUK KONTEN TAB ---

  // 1. Fungsi Utama Pemisah Konten
  Widget _buildTabContent(TripDetailController controller, TripDetailModel trip) {
    if (controller.activeTab.value == 'Details') {
      // Konten Tab Details
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Statistics (Distance, Rating, Temp)
          _buildStatisticsRow(trip),
          const SizedBox(height: 30),

          // Description Header
          Text(
            'Description',
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Description Content
          Text(
            trip.description,
            style: Get.textTheme.bodyMedium?.copyWith(height: 1.5, color: Colors.grey[700]),
          ),
          const SizedBox(height: 30),

          // Group Members
          _buildGroupMembersWidget(),
          const SizedBox(height: 30),

          // Detail Trip Tambahan (Informasi Perjalanan)
          Text(
            'Informasi Perjalanan',
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTripInfoRow(Iconsax.calendar_tick_outline, "Tanggal Mulai", trip.startDate),
          _buildTripInfoRow(Iconsax.clock_outline, "Waktu", "${trip.departureTime.substring(0, 5)} - ${trip.returnTime.substring(0, 5)}"),
          _buildTripInfoRow(Iconsax.user_tag_outline, "Penyedia", trip.provider.companyName),
        ],
      );
    } else {
      // Konten Tab Review
      return _buildReviewContent();
    }
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

  // 2. Konten Review
  Widget _buildReviewContent() {
    // Data review placeholder
    final List<Map<String, dynamic>> reviews = [
      {'name': 'Risa Putri', 'rating': 5.0, 'comment': 'Trip yang sangat mengesankan! Pemandu ramah dan destinasi sesuai ekspektasi. Sangat direkomendasikan.'},
      {'name': 'Aldi Wijaya', 'rating': 4.5, 'comment': 'Akomodasi bagus, tapi jadwal sedikit padat. Overall pengalaman yang menyenangkan!'},
      {'name': 'Santi Dewi', 'rating': 5.0, 'comment': 'Pelayanannya bintang 5! Semua berjalan lancar dari awal hingga akhir.'},
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

        const SizedBox(height: 20),

        // Tombol Tulis Review
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Iconsax.edit_outline, size: 20),
            label: const Text('Tulis Review Anda'),
            onPressed: () => Get.snackbar('Review', 'Membuka form review...', snackPosition: SnackPosition.BOTTOM),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryColor),
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        )
      ],
    );
  }

  // 3. Widget untuk setiap ulasan
  Widget _buildReviewTile(String name, double rating, String comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Placeholder
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
              Text('1 hari lalu', style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)), // Tanggal placeholder
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

  // --- WIDGETS LAMA DENGAN KOREKSI ---

  // Perbaikan: Hapus SizedBox(width: 70) yang berlebihan
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
            width: 200, // Sesuaikan lebar agar Stack dan Text muat
            height: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Member Avatars Placeholder
                SizedBox(
                  width: 65, // Lebar khusus untuk stack avatar
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
                // Text sekarang berdampingan dengan Stack Avatar
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

  // Fungsi untuk membangun baris tab (tempat penampung 2 tab)
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

  // Fungsi yang mengembalikan widget tab tunggal
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
            // Tampilan tab yang tidak dipilih (hanya text) sudah benar,
            // tidak perlu border jika ingin tampilan seperti gambar
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

  // --- WIDGETS LAINNYA (TIDAK BERUBAH SIGNIFIKAN) ---

  // ... (Sisanya dari _buildCircleButton hingga _imageDestination tetap sama atau hanya perbaikan minor pada parameter)

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

// ... (widget lainnya)
  Widget _imageDestination(Size size, {required String? companyProviderImageURL, required String? imageURL, required String? location, required String? title}){
    return Container(
      width: double.infinity,
      height: size.height / 2.5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
          image: DecorationImage(image: NetworkImage(imageURL!), fit: BoxFit.cover)
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 35.0),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.all(9.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Icon(Iconsax.arrow_left_outline),
                  ),
                ),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                      image: DecorationImage(image: NetworkImage("https://provider-travelers.karyadeveloperindonesia.com/$companyProviderImageURL"))
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 20.0, // Naikkan sedikit agar tidak terlalu mepet
              left: 0.0,
              right: 0.0,
              child: ClipRRect( // 1. Tambahkan ClipRRect untuk memotong blur sesuai border radius
                borderRadius: BorderRadius.circular(15.0), // Gunakan radius yang lebih besar agar lebih modern
                child: BackdropFilter( // 2. Tambahkan BackdropFilter
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Atur tingkat blur
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
                          child: Row( // Gunakan Row untuk menampung teks dan ikon (opsional)
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