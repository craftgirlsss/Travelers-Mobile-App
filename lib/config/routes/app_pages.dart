import 'package:get/get.dart';
import 'package:travelers/modules/auth/views/login_screen.dart';
import 'package:travelers/modules/settings/bindings/edit_profile_binding.dart';
import 'package:travelers/modules/settings/views/edit_profile_screen.dart';
import 'package:travelers/modules/trip/views/trip_search_page.dart';
import '../../modules/auth/binding/auth_binding.dart';
import '../../modules/auth/binding/register_binding.dart';
import '../../modules/auth/controllers/forgot_password_controller.dart';
import '../../modules/auth/controllers/otp_controller.dart';
import '../../modules/auth/controllers/reset_password_controller.dart';
import '../../modules/auth/views/forgot_password_screen.dart';
import '../../modules/auth/views/otp_verification_screen.dart';
import '../../modules/auth/views/register_screen.dart';
import '../../modules/auth/views/reset_password_screen.dart';
import '../../modules/booking/bindings/booking_binding.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_screen.dart';
import '../../modules/settings/controllers/about_controller.dart';
import '../../modules/settings/views/about_screen.dart';
import '../../modules/trip/bindings/trip_binding.dart';
import '../../modules/trip/views/trip_detail_screen.dart';
import '../../modules/vouchers/bindings/my_vouchers_binding.dart';
import '../../modules/vouchers/views/my_vouchers_screen.dart';
import 'app_routes.dart';

class AppPages {
  // Rute awal yang akan dimuat (misalnya, layar beranda setelah splash/login)
  static const INITIAL = Routes.HOME;

  static final routes = [
    // --- Rute Auth ---
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(), // Ganti dengan View yang sebenarnya
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
    ),

    GetPage(
      name: Routes.OTP_VERIFICATION,
      page: () => const OtpVerificationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OtpController>(() => OtpController());
      }),
    ),

    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());
      }),
    ),

    // --- Rute Register ---
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),

    GetPage(
      name: Routes.TRIP_DETAIL,
      page: () => const TripDetailScreen(),
      binding: TripBinding(),
    ),

    GetPage(
      name: Routes.TRIP_SEARCH,
      page: () => const TripSearchPage(),
      binding: TripBinding(),
    ),

    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      bindings: [
        HomeBinding(),
        BookingBinding(), // <-- Tambahkan ini
      ],
    ),

    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
    ),

    GetPage(
      name: Routes.MY_VOUCHERS,
      page: () => const MyVouchersScreen(),
      binding: MyVouchersBinding(),
    ),

    GetPage(
      name: Routes.ABOUT,
      page: () => const AboutScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AboutController>(() => AboutController());
      }),
    ),
  ];
}