// lib/modules/home/views/pages/tab_wishlist.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../data/models/wishlist_trip_model.dart';
import '../../controllers/home_controller.dart';
import '../../../../presentation/themes/app_theme.dart';
import '../../../../config/routes/app_routes.dart';

class WishlistTabView extends GetView<HomeController> {
  const WishlistTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Wishlist',
                style: Get.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 32),
              ),
            ),

            // Konten: Loading, Empty, atau List
            Expanded(
              child: controller.isWishlistLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _buildWishlistContent(context, controller.wishlistTrips),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWishlistContent(BuildContext context, List<WishlistTripModel> trips) {
    if (trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.heart_add_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 20),
              Text(
                'Wishlist Anda Kosong',
                style: Get.textTheme.titleLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan trip favorit Anda ke sini agar mudah ditemukan.',
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilan daftar trip yang difavoritkan
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return _buildWishlistCard(trips[index]);
      },
    );
  }

  Widget _buildWishlistCard(WishlistTripModel trip) {
    final String priceText = "Rp${(trip.price / 1000).toStringAsFixed(0)}K";

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.TRIP_DETAIL, arguments: trip.uuid);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Trip
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
                image: trip.mainImageUrl != null
                    ? DecorationImage(
                  image: NetworkImage("https://provider-travelers.karyadeveloperindonesia.com/${trip.mainImageUrl!}"),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: trip.mainImageUrl == null ? const Center(child: Icon(Iconsax.image_outline, size: 30, color: Colors.white70)) : null,
            ),
            const SizedBox(width: 15),

            // Detail Trip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title ?? 'Unknown Title',
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
                          trip.location ?? 'Unknown Title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Harga dan Durasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.duration ?? '0 Day',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        priceText,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ikon Hapus (Remove from Wishlist)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Iconsax.close_circle_outline, color: Colors.red),
                onPressed: () {
                  // TODO: Tambahkan fungsi hapus wishlist di Controller
                  Get.snackbar('Hapus', 'Trip "${trip.title}" dihapus dari Wishlist', snackPosition: SnackPosition.BOTTOM);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}