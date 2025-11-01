// lib/modules/vouchers/bindings/my_vouchers_binding.dart

import 'package:get/get.dart';
import '../controllers/my_vouchers_controller.dart';

class MyVouchersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyVouchersController>(() => MyVouchersController());
  }
}