// lib/modules/trip/bindings/trip_binding.dart

import 'package:get/get.dart';
import '../controllers/trip_detail_controller.dart';
import '../../../data/repositories/trip_repository.dart';

class TripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripDetailController>(() => TripDetailController());
  }
}