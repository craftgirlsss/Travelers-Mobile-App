import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'data/providers/api_provider.dart';
import 'data/services/permission_service.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/themes/theme_controller.dart';
import 'config/routes/app_pages.dart';
import 'config/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(ApiService());
  Get.put(PermissionService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Travelers',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      translations: AppTranslations(),
      locale: const Locale('id', 'ID'),
      debugShowCheckedModeBanner: false,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppPages.INITIAL, // Asumsi ini mengarah ke /home
      getPages: AppPages.routes,
      // Binding awal jika ada (misalnya, untuk controller global)
      // initialBinding: RootBinding(), // Anda dapat menambahkannya jika diperlukan
    );
  }
}