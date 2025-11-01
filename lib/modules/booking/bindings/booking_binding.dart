// lib/modules/booking/bindings/booking_binding.dart

import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import '../../home/controllers/home_controller.dart'; // Jika BookingTabView ada di dalam Home

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    // Controller ini akan digunakan untuk tab booking
    Get.lazyPut<BookingController>(() => BookingController());

    // Pastikan TripRepository sudah terdaftar (biasanya di main binding)
    // Jika belum: Get.lazyPut<TripRepository>(() => TripRepository());
  }
}