// lib/modules/home/bindings/home_binding.dart

import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/repositories/trip_repository.dart'; // Import Repository

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Daftarkan Repository (agar bisa diakses oleh Controller)
    Get.lazyPut<TripRepository>(() => TripRepository());

    // 2. Daftarkan Controller
    Get.lazyPut<HomeController>(() => HomeController());
  }
}