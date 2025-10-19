// lib/modules/home/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/trip_model.dart';
import '../views/pages/tab_settings.dart';
import '../../../data/services/permission_service.dart';
import '../views/pages/tab_home.dart'; // Import tab-tab yang akan dibuat

class HomeController extends GetxController {
  final TripRepository _repository = Get.find<TripRepository>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final RxString locationName = 'Memuat Lokasi...'.obs;

  // State untuk VOUCHER
  final RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final RxBool isVoucherLoading = true.obs;

  // State Dashboard
  final RxInt selectedIndex = 0.obs;

  // State Data
  final Rx<ProfileModel?> userProfile = Rx<ProfileModel?>(null);
  final RxList<TripModel> allTrips = <TripModel>[].obs;

  final RxBool isProfileLoading = true.obs;
  final RxBool isTripsLoading = true.obs;

  // Daftar Halaman untuk BottomNavigationBar
  final List<Widget> pages = [
    const HomeTabView(), // 1. Home
    const Center(child: Text('Bookings')), // 2. Booked
    const Center(child: Text("Search Placeholder")), // Index 3 (FAB)
    const Center(child: Text('Notifikasi')), // 4. Notifikasi
    const SettingsTabView(), // Index 5 (Pengaturan)
  ];

  @override
  void onInit() {
    fetchUserDataAndTrips();
    getCurrentLocationName();
    fetchVouchers();
    super.onInit();
  }

  void changePage(int index) {
    if (index != 2) { // Index 2 adalah Search (Floating Button)
      selectedIndex.value = index;
    }
  }

  void fetchUserDataAndTrips() async {
    // 1. Ambil Profil Pengguna
    isProfileLoading.value = true;
    final profile = await _repository.fetchUserProfile();
    userProfile.value = profile;
    isProfileLoading.value = false;

    // 2. Ambil Daftar Trips
    isTripsLoading.value = true;
    final trips = await _repository.fetchAllTrips();
    allTrips.assignAll(trips);
    isTripsLoading.value = false;
  }

  void openCameraFeature() async {
    final isGranted = await _permissionService.checkPermissionStatus(Permission.camera);

    if (isGranted) {
      // Izin ada, lanjutkan membuka kamera
      Get.log("Kamera siap digunakan.");
    } else {
      // Izin tidak ada, minta izin
      final status = await _permissionService.requestAllPermissions();

      if (status[Permission.camera]?.isGranted == true) {
        Get.log("Izin kamera baru saja diberikan, buka kamera.");
      } else {
        Get.snackbar("Akses Ditolak", "Akses kamera ditolak. Tidak dapat menggunakan fitur ini.");
      }
    }
  }

  // Fungsi untuk memuat data voucher
  Future<void> fetchVouchers() async {
    isVoucherLoading.value = true;
    final result = await _repository.fetchVouchers();
    vouchers.assignAll(result);
    isVoucherLoading.value = false;
  }

  // Fungsi utama untuk mendapatkan nama lokasi
  Future<void> getCurrentLocationName() async {
    try {
      // 1. Cek dan Tangani Izin Lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationName.value = 'Layanan lokasi dinonaktifkan.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationName.value = 'Izin lokasi ditolak.';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationName.value = 'Izin lokasi ditolak permanen. Silakan ubah di pengaturan.';
        return;
      }

      // 2. Dapatkan Koordinat Lokasi
      locationName.value = 'Mendapatkan koordinat...';
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low, // Akurasi rendah lebih cepat
          timeLimit: const Duration(seconds: 10)
      );

      // 3. Geocoding (Koordinat -> Alamat)
      locationName.value = 'Mencari nama lokasi...';
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        // Contoh: Ambil nama sub-lokalitas (kelurahan/kecamatan) dan kota/kabupaten
        final String subLocality = place.subLocality ?? place.locality ?? '';
        final String city = place.subAdministrativeArea ?? place.administrativeArea ?? '';

        String result = 'Lokasi Tidak Dikenal';
        if (subLocality.isNotEmpty && city.isNotEmpty) {
          result = '$subLocality, $city';
        } else if (city.isNotEmpty) {
          result = city;
        } else if (subLocality.isNotEmpty) {
          result = subLocality;
        }

        locationName.value = result;
      } else {
        locationName.value = 'Tidak dapat menemukan nama lokasi.';
      }

    } catch (e) {
      // Tangani kesalahan umum (timeout, dll.)
      locationName.value = 'Gagal memuat lokasi: ${e.toString().split(':')[0]}';
      print('ERROR GETTING LOCATION: $e');
    }
  }
}