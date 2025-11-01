// lib/modules/trip/views/trip_search_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../config/routes/app_routes.dart';
import '../controllers/trip_search_controller.dart';
import '../../../presentation/themes/app_theme.dart';

class TripSearchPage extends GetView<TripSearchController> {
  const TripSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller jika belum
    Get.put(TripSearchController());
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          // Kosongkan title, input ada di bottom
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: _buildSearchBarInput(),
          ),
        ),
        body: Column(
          children: [
            // Tab Bar
            _buildTabBar(),

            // TabBarView (Konten Utama)
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildTabContent(0), // Destinasi
                  _buildTabContent(1), // Titik Kumpul
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSearchBarInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: TextField(
        controller: controller.searchInputController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => controller.performSearch(value),
        decoration: InputDecoration(
          hintText: 'Cari destinasi atau lokasi...',
          hintStyle: TextStyle(color: Get.textTheme.bodySmall?.color?.withOpacity(0.5)),
          prefixIcon: Icon(Iconsax.search_normal_1_outline, color: Colors.grey),
          suffixIcon: controller.currentQuery.value.isNotEmpty
              ? IconButton(
            icon: Icon(Iconsax.close_circle_outline),
            onPressed: () => controller.searchInputController.clear(),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller.tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(
              text: 'Destinasi',
              icon: Icon(Iconsax.location_outline, size: 20)
          ),
          Tab(
              text: 'Titik Kumpul',
              icon: Icon(Iconsax.map_1_outline, size: 20)
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    return Obx(() {
      final tabLabel = tabIndex == 0 ? 'Destinasi' : 'Titik Kumpul';

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!controller.hasSearched.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.search_status_outline, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text(
                'Cari berdasarkan $tabLabel',
                style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.empty_wallet_outline, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text(
                'Tidak ada trip ditemukan untuk "${controller.currentQuery.value}"',
                style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      }

      // Tampilkan Hasil (ListView)
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final trip = controller.searchResults[index];
          // Menggunakan ModernTripCard, tetapi diubah agar tampil vertikal (ListTile-style)
          return _buildVerticalTripCard(trip);
        },
      );
    });
  }

  // Widget untuk menampilkan hasil pencarian secara vertikal (mirip ListTile)
  Widget _buildVerticalTripCard(trip) {
    // Anggap trip adalah TripModel, dan Anda perlu data dari ModernTripCard
    final String mainImageUrl = trip.mainImageUrl ?? '';
    final String priceText = "Rp${(trip.price / 1000).toStringAsFixed(0)}K";

    return GestureDetector(
      onTap: (){
        Get.toNamed(Routes.TRIP_DETAIL, arguments: trip.uuid);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: mainImageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage("https://provider-travelers.karyadeveloperindonesia.com/$mainImageUrl"),
                  fit: BoxFit.cover,
                )
                    : null,
                color: Colors.grey[200],
              ),
              child: mainImageUrl.isEmpty ? const Center(child: Icon(Iconsax.image_outline, size: 30, color: Colors.white70)) : null,
            ),
            const SizedBox(width: 15),

            // Detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Iconsax.location_outline, size: 14, color: Colors.grey),
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
                ],
              ),
            ),

            // Harga & Durasi
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trip.duration,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}