// lib/modules/trip/controllers/trip_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/trip_detail_model.dart';
import '../../../data/repositories/trip_repository.dart';

class TripDetailController extends GetxController {
  final TripRepository _repository = Get.find<TripRepository>();

  // Ambil UUID dari arguments
  final String tripUuid = Get.arguments as String;

  final Rx<TripDetailModel?> tripDetail = Rx<TripDetailModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString activeTab = 'Details'.obs; // Untuk tab Details/Review

  @override
  void onInit() {
    fetchTripDetails(tripUuid);
    super.onInit();
  }

  Future<void> fetchTripDetails(String uuid) async {
    isLoading.value = true;
    final detail = await _repository.fetchTripDetail(uuid);
    tripDetail.value = detail;
    isLoading.value = false;

    if (detail == null) {
      // PERBAIKAN: Hapus isAutism: true
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

  void bookNow() {
    Get.snackbar('Booking', 'Mengarahkan ke halaman pemesanan untuk ${tripDetail.value?.title}', snackPosition: SnackPosition.BOTTOM);
    // TODO: Navigasi ke halaman checkout
  }
}