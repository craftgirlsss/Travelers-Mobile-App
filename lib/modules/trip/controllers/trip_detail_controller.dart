import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelers/config/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/booking_status_model.dart';
import '../../../data/models/trip_detail_model.dart';
import '../../../data/repositories/trip_repository.dart';

class TripDetailController extends GetxController {
  final TripRepository _repository = Get.find<TripRepository>();
  final String tripUuid = Get.arguments as String;
  final Rx<TripDetailModel?> tripDetail = Rx<TripDetailModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString activeTab = 'Details'.obs;
  final RxBool isBookingLoading = false.obs;
  final RxInt numOfPeople = 1.obs;
  // UUID Booking yang didapat setelah booking berhasil atau dari fetchDetail
  final Rx<String?> bookedUuid = Rx<String?>(null);
  final RxInt calculatedPrice = 0.obs;

  @override
  void onInit() {
    fetchTripDetails(tripUuid);
    // Listener untuk memperbarui harga ketika numOfPeople berubah
    ever(numOfPeople, (_) => updatePrice());
    super.onInit();
  }

  void setNumOfPeople(int count) {
    if (count > 0) {
      numOfPeople.value = count;
    }
  }

  int calculateTotalPrice(int count) {
    final basePrice = tripDetail.value?.price ?? 0;
    return basePrice * count;
  }

  void updatePrice() {
    calculatedPrice.value = calculateTotalPrice(numOfPeople.value);
  }

  Future<void> performBooking(int peopleCount) async {
    if (isBookingLoading.value || bookedUuid.value != null) return;
    isBookingLoading.value = true;
    try {
      final response = await _repository.createBooking(
        tripUuid: tripUuid,
        numOfPeople: peopleCount,
      );
      isBookingLoading.value = false;
      if (response.success && response.bookingUuid != null) {bookedUuid.value = response.bookingUuid;
        if (tripDetail.value != null) {
          final currentDetail = tripDetail.value!;
          final newBookingStatus = currentDetail.bookingStatus?.copyWith(
            booked: true,
            paid: false,
            bookingUuid: response.bookingUuid, // Simpan UUID booking baru
          ) ?? BookingStatusModel(
            booked: true,
            paid: false,
            bookingUuid: response.bookingUuid,
          );
          tripDetail.value = currentDetail.copyWith(
            bookingStatus: newBookingStatus,
          );
        }

        Get.snackbar(
          'Booking Berhasil! 🎉',
          'Silakan lanjutkan ke pembayaran.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // ✅ REVISI PEMANGGILAN KE HALAMAN PEMBAYARAN
        viewPaymentDetail(response.bookingUuid!);

      } else {
        // GAGAL LOGIS (Respon 200/201 tapi status: fail)
        Get.snackbar(
          'Booking Gagal 😔',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.log('ERROR BOOKING: $e');
    } finally {
      isBookingLoading.value = false;
    }
  }

  // Fungsi untuk memuat detail trip
  Future<void> fetchTripDetails(String uuid) async {
    isLoading.value = true;
    final detail = await _repository.fetchTripDetailAuthenticated(uuid);
    tripDetail.value = detail;
    isLoading.value = false;

    if (detail != null) {
      // Inisialisasi status booking dan harga awal
      bookedUuid.value = detail.bookingStatus?.bookingUuid;
      updatePrice();
    } else {
      Get.snackbar(
        'Error',
        'Gagal memuat detail perjalanan. Coba periksa koneksi atau UUID.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void changeTab(String tabName) {
    activeTab.value = tabName;
  }

  // FUNGSI INTI UNTUK TOMBOL "BOOK NOW" DI BOTTOM NAV BAR
  void bookNow() {
    // Reset jumlah orang dan harga untuk dialog pemesanan
    numOfPeople.value = 1;
    updatePrice();
  }

  void viewPaymentDetail([String? uuid]) {
    final targetBookingUuid = uuid ?? bookedUuid.value; // Menggunakan bookedUuid.value dari state jika tidak ada parameter

    if (targetBookingUuid == null) {
      Get.snackbar('Error', 'UUID Booking tidak ditemukan.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.toNamed(Routes.PAYMENT_DETAIL, arguments: {
      'bookingUuid': targetBookingUuid,
      'tripUuid': tripUuid, // Mengambil tripUuid dari state controller
    });
  }

  // FUNGSI UNTUK CANCEL BOOK
  void cancelBook() {
    final targetUuid = bookedUuid.value;
    if (targetUuid == null) {
      Get.snackbar('Error', 'Tidak ada booking aktif untuk dibatalkan.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Ganti ini dengan navigasi riil Anda, biasanya ke halaman konfirmasi pembatalan
    Get.toNamed('/cancel_booking', arguments: targetUuid);
  }

  // Fungsi helper lainnya (launchURL) tetap sama
  Future<void> launchURL(String url) async {
    if (url.isEmpty) {
      Get.snackbar('Error', 'URL tidak valid.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Tidak dapat membuka $url', snackPosition: SnackPosition.BOTTOM);
    }
  }
}