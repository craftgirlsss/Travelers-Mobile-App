// lib/modules/home/controllers/home_controller.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelers/data/repositories/user_repository.dart';
import '../../../data/models/international_trip_model.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/models/wishlist_trip_model.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../main.dart';
import '../../../services/notification_service.dart';
import '../views/pages/tab_bookings.dart';
import '../views/pages/tab_settings.dart';
import '../../../data/services/permission_service.dart';
import '../views/pages/tab_home.dart';
import '../views/pages/tab_wishlist.dart'; // Import tab-tab yang akan dibuat

class HomeController extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final TripRepository _repository = Get.find<TripRepository>();
  final UserRepository _userRepository = Get.put(UserRepository());
  final PermissionService _permissionService = Get.find<PermissionService>();
  final RxList<WishlistTripModel> wishlistTrips = <WishlistTripModel>[].obs;
  final RxBool isWishlistLoading = true.obs;
  final RxString locationName = 'Memuat Lokasi...'.obs;

  // 💥 STATE BARU: Daftar Trip Internasional
  final RxBool isInternationalLoading = true.obs;
  final RxBool isLocalLoading = true.obs;
  final RxList<InternationalTripModel> internationalTrips = RxList([]);
  final RxList<InternationalTripModel> localTrips = RxList([]);

  // State untuk melacak voucher yang sedang di-claim atau yang sudah berhasil di-claim.
  // Map<voucherUuid, RxBool(isLoading)>
  final RxMap<String, RxBool> claimLoadingStates = <String, RxBool>{}.obs;
  // Set<voucherUuid> yang sudah berhasil diklaim.
  final RxSet<String> claimedVoucherUuids = <String>{}.obs;
  final RxSet<String> claimedVoucherUuidsFromApi = <String>{}.obs;

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
    const BookingTabView(),
    const Center(child: Text("Search Placeholder")), // Index 3 (FAB)
    const WishlistTabView(),
    const SettingsTabView(), // Index 5 (Pengaturan)
  ];

  // --- Fungsi Helper untuk Mendapatkan Info Perangkat ---
  Future<Map<String, String>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String platform = 'unknown';
    String name = 'Unknown Device';
    String model = 'Unknown Model';

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        platform = 'android';
        name = androidInfo.model;
        model = androidInfo.product;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        platform = 'ios';
        name = iosInfo.name ?? 'iOS Device';
        model = iosInfo.model;
      } else if (kIsWeb) {
        // Handle web jika diperlukan
        final WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        platform = 'web';
        name = webInfo.browserName.toString();
        model = webInfo.platform ?? 'Web Browser';
      }
    } catch (e) {
      Get.log("Failed to get device info: $e");
    }

    return {
      'platform': platform,
      'name': name,
      'model': model,
    };
  }

  // --- Modifikasi Fungsi Setup FCM ---
  void setupFCM() async {
    // 1. Inisialisasi Notifikasi Lokal (dari jawaban sebelumnya)
    LocalNotificationService.initialize();

    // 2. Minta Izin Notifikasi
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 3. Ambil Token FCM
      final fcmToken = await messaging.getToken();

      if (fcmToken != null) {
        // 4. Ambil Info Perangkat
        final deviceInfo = await _getDeviceInfo();

        // 5. Kirim ke API Backend
        final success = await _userRepository.updateFCMToken(
          fcmToken: fcmToken,
          platform: deviceInfo['platform']!,
          deviceName: deviceInfo['name']!,
          deviceModel: deviceInfo['model']!,
        );
        if (success) {
          Get.log("FCM Token successfully sent to backend.");
        } else {
          Get.log("Failed to send FCM Token to backend.");
        }

        // Untuk simulasi:
        Get.log("FCM Token obtained: $fcmToken");
        Get.log("Device Info: ${deviceInfo}");

        // 6. Setup Listener Pesan
        _setupMessageListeners(); // (dari jawaban sebelumnya)
      }
    } else {
      Get.log('User denied notification permission');
    }
  }

  // --- Setup Listener Pesan ---
  void _setupMessageListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) { // 💥 Perbaikan di sini
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
    });

    // B. Ketika user mengklik notifikasi (dari background/terminated)
    // GANTI: _messaging.onMessageOpenedApp.listen
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) { // 💥 Perbaikan di sini
      print('A new onMessageOpenedApp event was published!');
    });

    // C. Handle pesan dari status Terminated (Aplikasi Tertutup)
    // Ini adalah satu-satunya yang diakses melalui instance (non-static)
    _messaging.getInitialMessage().then((RemoteMessage? message) { // Tidak perlu diubah
      if (message != null) {
        print('App launched from terminated state via notification!');
        // ...
      }
    });

    // D. Pendaftaran handler latar belakang (Biasanya di main.dart)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler); // Ini sudah benar
  }

  // 💥 FUNGSI BARU: Master Refresh Data
  Future<void> refreshData() async {
    // 1. Reset Loading States (opsional, tapi bagus untuk konsistensi)
    isProfileLoading.value = true;
    isTripsLoading.value = true;
    isVoucherLoading.value = true;
    isWishlistLoading.value = true;

    // 2. Gunakan Future.wait untuk menjalankan semua fetch secara paralel dan lebih cepat
    await Future.wait([
      fetchUserDataAndTrips(isManualRefresh: true), // Set flag agar tidak menampilkan snackbar
      getCurrentLocationName(),
      fetchVouchers(),
      fetchWishlist(),
      fetchClaimedVouchers(),
    ] as Iterable<Future>);

    // 3. (Opsional) Tampilkan pesan sukses setelah semua selesai
    Get.snackbar('Berhasil', 'Data halaman Beranda telah diperbarui.',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // FUNGSI BARU: Memuat Trip Internasional (Ubah Tipe Return)
  Future<void> fetchInternationalTrips() async {
    isInternationalLoading.value = true;
    try {
      final trips = await _repository.fetchInternationalTrips();
      internationalTrips.assignAll(trips);
    } catch (e) {
      Get.log("Error loading international trips: $e");
    } finally {
      isInternationalLoading.value = false;
    }
  }

  Future<void> fetchLocalTrips() async {
    isLocalLoading.value = true;
    try {
      final trips = await _repository.fetchLocalTrips();
      localTrips.assignAll(trips);
    } catch (e) {
      Get.log("Error loading international trips: $e");
    } finally {
      isLocalLoading.value = false;
    }
  }

  @override
  void onInit() {
    setupFCM();
    fetchUserDataAndTrips();
    getCurrentLocationName();
    fetchInternationalTrips();
    fetchLocalTrips();
    fetchVouchers();
    fetchWishlist();
    fetchClaimedVouchers(); // <-- Panggilan baru
    super.onInit();
  }

  void changePage(int index) {
    if (index != 2) { // Index 2 adalah Search (Floating Button)
      selectedIndex.value = index;
    }
  }

  void fetchUserDataAndTrips({bool isManualRefresh = false}) async {
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

  // Fungsi untuk memuat data wishlist (Menggunakan model baru)
  Future<void> fetchWishlist() async {
    isWishlistLoading.value = true;
    // Repository sekarang mengembalikan List<WishlistTripModel>
    final result = await _repository.fetchWishlist();
    wishlistTrips.assignAll(result);
    isWishlistLoading.value = false;
  }

  // --- Fungsi Baru/Modifikasi ---

  Future<void> fetchClaimedVouchers() async {
    try {
      final result = await _repository.fetchClaimedVouchers();
      // Simpan semua UUID yang diklaim ke dalam state reaktif
      claimedVoucherUuidsFromApi.assignAll(result);
    } catch (e) {
      Get.log('Error saat memuat daftar voucher klaim: $e');
    }
  }

  // Modifikasi fungsi klaim (setelah berhasil)
  Future<void> claimVoucher(VoucherModel voucher) async {
    final uuid = voucher.uuid;

    // 1. Set Loading State
    claimLoadingStates[uuid] = true.obs;

    final result = await _repository.claimVoucher(uuid);

    // 2. Hapus Loading State
    claimLoadingStates.remove(uuid);

    if (result['success'] == true) {
      // 3. Update Status Otoritatif setelah klaim sukses
      // Tambahkan UUID ke daftar yang diklaim dari API, tanpa perlu refresh semua data
      claimedVoucherUuidsFromApi.add(uuid);
      await fetchVouchers();

      Get.snackbar(
          'Voucher Diklaim',
          result['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white
      );
    } else {
      // ... (error handling)
    }
  }

  // Helper untuk View: Mengecek apakah voucher sedang dalam proses loading
  bool isVoucherClaiming(String uuid) {
    return claimLoadingStates[uuid]?.value ?? false;
  }

  // Helper untuk View: Mengecek apakah voucher sudah berhasil diklaim
  @override
  bool isVoucherClaimed(String uuid) {
    return claimedVoucherUuidsFromApi.contains(uuid);
  }
}