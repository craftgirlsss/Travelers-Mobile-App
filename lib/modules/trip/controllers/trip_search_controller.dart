// lib/modules/trip/controllers/trip_search_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/trip_repository.dart';

class TripSearchController extends GetxController with GetSingleTickerProviderStateMixin {
  final TripRepository _tripRepository = Get.find<TripRepository>();

  // State untuk Tab
  late TabController tabController;
  final RxInt activeTabIndex = 0.obs;

  // State untuk Input
  final TextEditingController searchInputController = TextEditingController();
  final RxString currentQuery = ''.obs;

  // State untuk Hasil
  final RxList<TripModel> searchResults = <TripModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabChange);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    searchInputController.dispose();
    super.onClose();
  }

  void _handleTabChange() {
    activeTabIndex.value = tabController.index;
    // Clear hasil dan reset state saat tab berubah
    searchResults.clear();
    hasSearched.value = false;
    currentQuery.value = '';
    searchInputController.clear();
  }

  // Dipanggil saat tombol search ditekan
  void performSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    isLoading.value = true;
    hasSearched.value = true;
    currentQuery.value = trimmedQuery;
    searchResults.clear();

    List<TripModel> results = [];

    try {
      if (activeTabIndex.value == 0) {
        // Tab 0: Pencarian Destinasi
        results = await _tripRepository.searchTripsByDestination(trimmedQuery);
      } else {
        // Tab 1: Pencarian Titik Kumpul
        results = await _tripRepository.searchTripsByGatheringPoint(trimmedQuery);
      }

      print(results);

      searchResults.assignAll(results);

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat hasil pencarian: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}