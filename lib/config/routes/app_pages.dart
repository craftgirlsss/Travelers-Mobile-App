import 'package:get/get.dart';
import 'package:travelers/modules/auth/views/login_screen.dart';
import 'package:travelers/modules/trip/views/trip_search_page.dart';
import '../../modules/auth/binding/auth_binding.dart';
import '../../modules/auth/binding/register_binding.dart';
import '../../modules/auth/views/register_screen.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_screen.dart';
import '../../modules/trip/bindings/trip_binding.dart';
import '../../modules/trip/views/trip_detail_screen.dart';
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

    // --- Rute Register ---
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),

    // --- Rute Utama (Home) ---
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(), // Ganti dengan View yang sebenarnya
      binding: HomeBinding(),
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

    // --- Rute Settings ---
    // GetPage(
    //   name: Routes.SETTINGS,
    //   page: () => const SettingsScreen(), // Ganti dengan View yang sebenarnya
    //   binding: SettingsBinding(),
    //   // Transisi opsional (misalnya, dari bawah ke atas)
    //   transition: Transition.cupertino,
    // ),

    // Tambahkan rute untuk BOOKING, PROFILE, dll. di sini
  ];
}