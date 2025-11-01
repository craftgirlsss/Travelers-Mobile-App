// lib/modules/booking/controllers/booking_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/trip_repository.dart';

class BookingController extends GetxController with GetSingleTickerProviderStateMixin {
  final TripRepository _tripRepository = Get.find<TripRepository>();

  // State
  final RxList<BookingModel> allBookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;

  // State untuk Tab
  late TabController tabController;
  final List<String> tabs = ['Paid', 'Unpaid', 'Overdue'];

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    fetchBookings();
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final result = await _tripRepository.fetchBookingHistory();
      allBookings.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat pemesanan: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Filtered Lists (Reactive) ---

  // Paid: status == 'paid'
  RxList<BookingModel> get paidBookings => allBookings
      .where((booking) => booking.status.toLowerCase() == 'paid')
      .toList()
      .obs;

  // Unpaid: status == 'pending' (belum dibayar dan belum melewati tanggal trip)
  RxList<BookingModel> get unpaidBookings {
    return allBookings
        .where((booking) =>
    booking.status.toLowerCase() == 'pending' &&
        (DateTime.tryParse(booking.startDate) ?? DateTime.now())
            .isAfter(DateTime.now().subtract(const Duration(days: 1))) // Trip belum lewat
    )
        .toList()
        .obs;
  }

  // Overdue: status == 'pending' DAN trip sudah melewati tanggal start_date
  RxList<BookingModel> get overdueBookings {
    return allBookings
        .where((booking) =>
    booking.status.toLowerCase() == 'pending' &&
        (DateTime.tryParse(booking.startDate) ?? DateTime(1970))
            .isBefore(DateTime.now().subtract(const Duration(days: 1))) // Trip sudah lewat
    )
        .toList()
        .obs;
  }

  // Fungsi refresh data
  Future<void> refreshBookings() async {
    await fetchBookings();
  }
}