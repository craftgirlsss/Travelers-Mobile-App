// lib/modules/trip/controllers/trip_detail_controller.dart (FINAL REVISI)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // --- STATE BOOKING ---
  final RxBool isBookingLoading = false.obs;
  final RxInt numOfPeople = 1.obs;
  final Rx<String?> bookedUuid = Rx<String?>(null);
  final RxInt calculatedPrice = 0.obs;
  // --------------------

  @override
  void onInit() {
    fetchTripDetails(tripUuid);
    super.onInit();
  }

  // FUNGSI PUBLIK: Melakukan panggilan API Booking
  Future<void> performBooking(int peopleCount) async {
    if (isBookingLoading.value || bookedUuid.value != null) return;

    isBookingLoading.value = true;

    try {
      final response = await _repository.createBooking(
        tripUuid: tripUuid,
        numOfPeople: peopleCount,
      );

      if (response.success && response.bookingUuid != null) {
        bookedUuid.value = response.bookingUuid;

        // 💥 TAMBAHAN: Update status booking di model tripDetail secara lokal
        if (tripDetail.value != null) {
          final currentDetail = tripDetail.value!;
          // Buat BookingStatusModel baru
          final newBookingStatus = currentDetail.bookingStatus?.copyWith(
            booked: true, // Set status booking menjadi true
            paid: false,  // Belum dibayar
            // Jika Anda memiliki field bookingUuid di BookingStatusModel, set juga di sini
          ) ?? BookingStatusModel(
            booked: true,
            paid: false,
            // Inisialisasi properti lain jika diperlukan
          );

          // Ganti objek tripDetail agar GetX mendeteksi perubahan
          tripDetail.value = currentDetail.copyWith(
            bookingStatus: newBookingStatus,
          );
        } else {
          // GAGAL LOGIS (Respon 200/201 tapi status: fail)
          Get.snackbar(
            'Booking Gagal',
            response.message,
            backgroundColor: Colors.red.shade600, // Warna merah yang jelas
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      // GAGAL KONEKSI/PARSING
      Get.log('ERROR BOOKING: $e');
      Get.snackbar(
          'Error',
          'Terjadi kesalahan saat memproses booking atau koneksi.',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP
      );
    } finally {
      isBookingLoading.value = false;
    }
  }

  // 💥 FUNGSI CALCULATOR
  int calculateTotalPrice(int count) {
    final basePrice = tripDetail.value?.price ?? 0;
    return basePrice * count;
  }

  // Helper untuk membuka URL (tetap sama)
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

  // Fungsi untuk memuat detail trip
  Future<void> fetchTripDetails(String uuid) async {
    isLoading.value = true;
    final detail = await _repository.fetchTripDetailAuthenticated(uuid);
    tripDetail.value = detail;
    isLoading.value = false;

    if (detail == null) {
      Get.snackbar(
        'Error',
        'Gagal memuat detail perjalanan. Coba periksa koneksi atau UUID.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      calculatedPrice.value = calculateTotalPrice(numOfPeople.value);
    }
  }

  void changeTab(String tabName) {
    activeTab.value = tabName;
  }

  // FUNGSI UTAMA TOMBOL: bookNow() hanya bertugas untuk inisialisasi state dialog
  @override
  void bookNow() {
    numOfPeople.value = 1;
    calculatedPrice.value = calculateTotalPrice(1);
  }

  void cancelBook() {
    Get.snackbar('Booking', 'Mengarahkan ke halaman pembatalan pemesanan.', snackPosition: SnackPosition.BOTTOM);
  }

  void viewPaymentDetail() {
    Get.snackbar('Booking', 'Mengarahkan ke halaman detail pembayaran.', snackPosition: SnackPosition.BOTTOM);
  }
}