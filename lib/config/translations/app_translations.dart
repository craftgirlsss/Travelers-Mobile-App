import 'dart:ui';
import 'package:get/get.dart';
import 'id_ID.dart';
import 'en_US.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'id_ID': idID,
    'en_US': enUS,
  };

  // Fungsi utilitas untuk mengganti bahasa
  static void changeLocale(String langCode, String countryCode) {
    final locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);
  }
}