import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama Aplikasi
  static const Color primaryColor = Color(0xFF007AFF); // Biru khas traveling

  // --- Tema Terang (Light Theme) ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: const Color(0xFFFF9500), // Warna aksen oranye
      background: const Color(0xFFF2F2F7), // Latar belakang abu-abu muda
      surface: Colors.white, // Permukaan kartu/elemen putih
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0.5,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    // Definisi lain untuk textTheme, buttonTheme, dll.
  );

  // --- Tema Gelap (Dark Theme) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: const Color(0xFFFF9500),
      background: const Color(0xFF1C1C1E), // Latar belakang hitam gelap
      surface: const Color(0xFF2C2C2E), // Permukaan kartu/elemen abu-abu gelap
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF2C2C2E),
      foregroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    // Definisi lain untuk textTheme, buttonTheme, dll.
  );
}