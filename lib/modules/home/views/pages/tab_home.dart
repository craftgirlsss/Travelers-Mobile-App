// lib/modules/home/views/pages/home_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../data/models/voucher_model.dart'; // Pastikan ini terimport
import '../../controllers/home_controller.dart';
import '../../../../presentation/themes/app_theme.dart';

class HomeTabView extends GetView<HomeController> {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isTripsLoading.value && controller.allTrips.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.allTrips.isEmpty && !controller.isTripsLoading.value) {
        return Center(
            child: Text('Saat ini tidak ada trip yang tersedia.', style: Get.textTheme.titleMedium)
        );
      }

      return GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Header & Greeting ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: _buildHeader(context),
                ),

                // --- 2. Search Bar & Filter ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 20),

                // --- 3. Voucher Section ---
                // GANTI: Panggil fungsi _buildVoucherSection yang benar
                _buildVoucherSection(controller),
                const SizedBox(height: 30), // Naikkan sedikit padding untuk pemisah

                // --- 4. Travel Places Section (Horizontal List) ---
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10),
                  child: _buildSectionHeader(
                      title: 'Travel Places',
                      onShowMore: () => Get.snackbar('Navigasi', 'Melihat semua destinasi...', snackPosition: SnackPosition.BOTTOM)
                  ),
                ),

                // Sub-header (Pill Tabs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildPillTab('All', true),
                      _buildPillTab('Latest', false),
                      _buildPillTab('Popular', false),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Horizontal List View of Trips
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: controller.allTrips.length,
                    itemBuilder: (context, index) {
                      return ModernTripCard(trip: controller.allTrips[index]);
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // --- 5. Group Travel Section (Placeholder) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionHeader(
                      title: 'Group Travel',
                      onShowMore: () => Get.snackbar('Navigasi', 'Melihat semua grup travel...', snackPosition: SnackPosition.BOTTOM)
                  ),
                ),

                // Horizontal list Group Travel placeholder
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    children: [
                      _buildGroupCardPlaceholder('Kuakata Day Long Trip', '2 Days'),
                      _buildGroupCardPlaceholder('Bromo Sunrise', '1 Day'),
                      _buildGroupCardPlaceholder('Lombok Honeymoon', '5 Days'),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    });
  }

  // --- Widget Helper ---

  // PASTIKAN: Semua fungsi helper diletakkan di dalam HomeTabView

  // WIDGET VOUCHER SECTION
  Widget _buildVoucherSection(HomeController controller) {
    return Padding(
      // GANTI: Gunakan padding 16.0 untuk konsistensi
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Padding kanan untuk header
            child: _buildSectionHeader(
                title: 'Voucher',
                // Berikan fungsi yang benar untuk Show More (meskipun isViewAllVisible: false)
                onShowMore: () => Get.snackbar('Navigasi', 'Melihat semua Voucher', snackPosition: SnackPosition.BOTTOM)
            ),
          ),
          const SizedBox(height: 15),

          controller.isVoucherLoading.value
              ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
              : (controller.vouchers.isEmpty
              ? const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text('Tidak ada voucher aktif saat ini.'),
          )
              : SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.vouchers.length,
              itemBuilder: (context, index) {
                // Pastikan pemanggilan fungsi _buildVoucherCard dilakukan di sini
                return _buildVoucherCard(controller.vouchers[index]);
              },
            ),
          )),
        ],
      ),
    );
  }

  // WIDGET VOUCHER CARD
  Widget _buildVoucherCard(VoucherModel voucher) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // FIX: Hapus tanda seru (!) yang tidak perlu jika model sudah diatur non-nullable
    final Duration remaining = voucher.validUntil!.difference(DateTime.now());
    final String expiresIn = remaining.inDays > 0
        ? '${remaining.inDays} Hari'
        : '${remaining.inHours} Jam';

    final String valueText = voucher.type == 'percentage'
        ? '${voucher.value!.toInt()}% OFF'
        : currencyFormatter.format(voucher.value);

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Gambar Voucher (Opsional)
          if (voucher.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                voucher.imagePath!,
                width: 250,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.primaryColor.withOpacity(0.1)),
              ),
            ),

          // Isi Voucher dengan Overlay
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (voucher.imagePath == null)
                  ? AppTheme.primaryColor.withOpacity(0.8)
                  : Colors.black.withOpacity(0.4), // Overlay gelap jika ada gambar
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: Value & Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      valueText,
                      style: Get.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        voucher.code ?? '',
                        style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom: Min Purchase & Expiry
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Min. Pembelian: ${currencyFormatter.format(voucher.minPurchase)}',
                      style: Get.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sisa: ${voucher.remainingVouchers} kupon',
                          style: Get.textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                        Text(
                          'Berakhir dalam $expiresIn',
                          style: Get.textTheme.bodySmall?.copyWith(color: Colors.yellowAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Helper Lainnya (dipotong untuk keringkasan) ---

  Widget _buildHeader(BuildContext context) {
    // ... (kode _buildHeader)
    final profile = controller.userProfile.value;
    final name = profile?.name.split(' ').first ?? 'Pengguna';
    final pictureUrl = profile?.profilePictureUrl;
    final locationName = controller.locationName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Get.theme.primaryColor.withOpacity(0.2),
                    backgroundImage: pictureUrl != null
                        ? NetworkImage("https://example.com/images/$pictureUrl") as ImageProvider
                        : null,
                    child: pictureUrl == null ? Text(name[0], style: const TextStyle(color: Colors.white)) : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello $name',
                        style: Get.textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Icon(Iconsax.location_outline, size: 12),
                          const SizedBox(width: 4.0),
                          Text(locationName.value, style: Get.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.textalign_right_outline, size: 28),
              onPressed: () => Get.snackbar('Navigasi', 'Membuka Menu Samping...', snackPosition: SnackPosition.BOTTOM),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          'Explore the Beautiful World!',
          style: Get.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    // ... (kode _buildSearchBar)
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.shadowColor.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              readOnly: true,
              onTap: (){
                Get.toNamed(Routes.TRIP_SEARCH);
              },
              decoration: InputDecoration(
                hintText: 'Search Places',
                border: InputBorder.none,
                icon: Icon(Iconsax.search_normal_1_outline, color: Colors.grey[600]),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: const Icon(Iconsax.setting_4_outline, color: Colors.white),
            onPressed: () => Get.snackbar('Filter', 'Membuka Filter...', snackPosition: SnackPosition.BOTTOM),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onShowMore}) {
    // ... (kode _buildSectionHeader)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onShowMore,
          child: Row(
            children: [
              Text('Show More', style: TextStyle(color: AppTheme.primaryColor)),
              Icon(Iconsax.arrow_right_3_outline, size: 16, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillTab(String title, bool isSelected) {
    // ... (kode _buildPillTab)
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildGroupCardPlaceholder(String title, String duration) {
    // ... (kode _buildGroupCardPlaceholder)
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Get.theme.shadowColor.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(duration, style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const Spacer(),
          Row(
            children: [
              Text('Group Members', style: Get.textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor)),
              const Spacer(),
              const Text('20+', style: TextStyle(color: Colors.green)), // Placeholder member count
            ],
          ),
        ],
      ),
    );
  }
}

// --- Component Trip Card Baru (ModernTripCard) ---

class ModernTripCard extends StatelessWidget {
  final TripModel trip;
  const ModernTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // ... (kode ModernTripCard)
    return GestureDetector(
      onTap: (){
        // Pastikan Routes sudah terimport
        Get.toNamed(Routes.TRIP_DETAIL, arguments: trip.uuid);
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Trip
            Stack(
              children: [
                Container(
                  height: 145,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    image: trip.mainImageUrl != null
                        ? DecorationImage(
                      image: NetworkImage("https://provider-travelers.karyadeveloperindonesia.com/${trip.mainImageUrl!}"),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: trip.mainImageUrl == null ? const Center(child: Icon(Icons.image, size: 40, color: Colors.white70)) : null,
                ),
                // Ikon Bookmark di Sudut Kanan Atas
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.bookmark_border, size: 20, color: Get.theme.primaryColor),
                  ),
                ),
              ],
            ),

            // Detail Teks
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    trip.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Duration/Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.duration,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Get.theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Harga
                      Text(
                        "Rp${(trip.price / 1000).toStringAsFixed(0)}K", // Tampilkan dalam format RpX K
                        style: Get.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}