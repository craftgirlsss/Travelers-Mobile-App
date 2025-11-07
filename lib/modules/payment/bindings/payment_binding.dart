// lib/modules/payment/bindings/payment_detail_binding.dart
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';

class PaymentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentController>(() => PaymentController());
  }
}