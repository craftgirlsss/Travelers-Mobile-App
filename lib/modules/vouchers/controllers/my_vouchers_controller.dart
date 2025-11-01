// lib/modules/vouchers/controllers/my_vouchers_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/claimed_voucher_model.dart';
import '../../../data/repositories/trip_repository.dart';

class MyVouchersController extends GetxController with GetSingleTickerProviderStateMixin {
  final TripRepository _tripRepository = Get.find<TripRepository>();

  final RxBool isLoading = true.obs;
  final RxList<ClaimedVoucherModel> allVouchers = <ClaimedVoucherModel>[].obs;

  // Untuk Tab Bar
  late TabController tabController;
  final List<Tab> tabs = const [
    Tab(text: 'Belum Digunakan'),
    Tab(text: 'Sudah Digunakan'),
  ];

  // Filtered Lists (Computed/Getter)
  List<ClaimedVoucherModel> get unusedVouchers => allVouchers
      .where((v) => v.claimStatus == 'claimed' && !v.isExpired)
      .toList();

  List<ClaimedVoucherModel> get usedOrExpiredVouchers => allVouchers
      .where((v) => v.claimStatus == 'used' || v.isExpired)
      .toList();

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    fetchClaimedVouchers();
    super.onInit();
  }

  Future<void> fetchClaimedVouchers() async {
    isLoading.value = true;
    try {
      final Set<String> claimedUuids = await _tripRepository.fetchClaimedVouchers();

      // Catatan: Fungsi fetchClaimedVouchers di repository harus diubah
      // agar mengembalikan list penuh ClaimedVoucherModel, bukan hanya Set<String>.

      // Jika repository Anda sudah diubah untuk mengembalikan List<ClaimedVoucherModel>:
      // allVouchers.assignAll(await _tripRepository.fetchClaimedVouchers());

      // Jika Anda belum mengubah repository, anggap Anda memiliki fungsi baru di repository:
      final response = await _tripRepository.getClaimedVoucherData(); // Asumsi API baru yang mengembalikan data Model penuh
      allVouchers.assignAll(response);

    } catch (e) {
      Get.log('Error memuat voucher saya: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}