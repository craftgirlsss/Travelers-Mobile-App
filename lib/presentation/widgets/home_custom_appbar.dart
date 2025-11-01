import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../modules/home/controllers/home_controller.dart';
// Asumsi HomeController diakses untuk profile data

class HomeCustomAppBar extends GetView<HomeController> implements PreferredSizeWidget {
  const HomeCustomAppBar({super.key});

  // Tentukan tinggi total AppBar kustom Anda
  @override
  Size get preferredSize => const Size.fromHeight(160.0);

  @override
  Widget build(BuildContext context) {
    // Membungkus dengan Obx agar data profil dan lokasi reaktif
    return Obx(() {
      final profile = controller.userProfile.value;
      final name = profile?.name.split(' ').first ?? 'Pengguna';
      final pictureUrl = profile?.profilePictureUrl;
      final locationName = controller.locationName;

      // Menggunakan SafeArea untuk menghindari takik/notch pada layar
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Baris 1: Profile, Location, and Menu Icon ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 💥 Expanded untuk seluruh konten kiri (Avatar + Teks)
                  Expanded(
                    child: Row(
                      children: [
                        // Circle Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Get.theme.primaryColor.withOpacity(0.2),
                          backgroundImage: pictureUrl != null
                              ? NetworkImage("https://example.com/images/$pictureUrl") as ImageProvider
                              : null,
                          child: pictureUrl == null
                              ? Text(name[0], style: const TextStyle(color: Colors.white))
                              : null,
                        ),
                        const SizedBox(width: 10),

                        // Greeting and Location
                        // 💥 SOLUSI UTAMA: Wrap Column Teks dengan Flexible
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello $name',
                                style: Get.textTheme.titleMedium?.copyWith(fontSize: 16),
                                maxLines: 1, // Tambahkan batasan maxLines untuk sapaan
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  const Icon(Iconsax.location_outline, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4.0),
                                  // 💥 Gunakan Expanded untuk Text Lokasi
                                  Expanded(
                                    child: Text(
                                      locationName.value,
                                      style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification/Menu Icon
                  IconButton(
                    icon: const Icon(Iconsax.notification_outline, size: 24),
                    onPressed: () => Get.snackbar('Navigasi', 'Membuka Notifikasi...', snackPosition: SnackPosition.BOTTOM),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(), // Hilangkan batasan default padding
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // --- Baris 2: Main Title/Slogan ---
              Text(
                'Explore the Beautiful World!',
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}