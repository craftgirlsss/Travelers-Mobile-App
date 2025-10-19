// lib/data/providers/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../config/routes/app_routes.dart';

class ApiService extends GetxService {
  final GetStorage _box = GetStorage();
  final String _baseUrl = 'https://api-travelers.karyadeveloperindonesia.com';
  final String _refreshTokenUrl = 'https://api-travelers.karyadeveloperindonesia.com/refresh-token';

  // --- 1. Fungsi Umum untuk Mendapatkan Token dan Header ---
  Map<String, String> get _authHeaders {
    final token = _box.read('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- 2. Fungsi Utama untuk Melakukan Panggilan HTTP (Interception) ---
  Future<http.Response> get(String endpoint) async {
    return _sendRequest(() => http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _authHeaders,
    ));
  }

  Future<http.Response> post(String endpoint, {dynamic body}) async {
    return _sendRequest(() => http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _authHeaders,
      body: body,
    ));
  }

  // Metode untuk menangani request dan retry jika token expired
  Future<http.Response> _sendRequest(Future<http.Response> Function() request) async {
    http.Response response = await request();

    // Cek apakah response menunjukkan Unauthorized (misalnya status 401)
    // Asumsi: API akan mengembalikan status 401 jika token expired/invalid
    if (response.statusCode == 401) {
      Get.log("Token kedaluwarsa (401). Mencoba refresh token...");

      // Jika refresh token berhasil, coba request API yang sama lagi
      if (await _refreshToken()) {
        Get.log("Token berhasil di-refresh. Mencoba request ulang...");
        // Coba request (panggilan API awal) lagi dengan token baru
        return await request();
      } else {
        // Jika refresh token gagal, paksa logout
        Get.log("Refresh token gagal. Mengarahkan ke halaman login.");
        _forceLogout();
        // Kembalikan response 401 atau throw error agar controller tahu
        return response;
      }
    }

    return response;
  }

  // --- 3. Fungsi untuk Refresh Token ---
  Future<bool> _refreshToken() async {
    final refreshToken = _box.read('refreshToken');

    if (refreshToken == null) {
      Get.log("Refresh token tidak ditemukan.");
      return false; // Tidak bisa refresh
    }

    try {
      final refreshResponse = await http.post(
        Uri.parse(_refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      final refreshData = jsonDecode(refreshResponse.body);

      if (refreshResponse.statusCode == 200 && refreshData['status'] == 'success') {
        // Refresh berhasil! Simpan token baru
        final newAccessToken = refreshData['data']['token'];
        final newRefreshToken = refreshData['data']['refresh_token'];

        await _box.write('token', newAccessToken);
        await _box.write('refreshToken', newRefreshToken);

        Get.log("Token baru berhasil disimpan.");
        return true;
      } else {
        // Refresh gagal (Refresh token invalid/expired)
        Get.log("Refresh API gagal: ${refreshData['message']}");
        return false;
      }
    } catch (e) {
      Get.log("Kesalahan saat memanggil Refresh API: $e");
      return false;
    }
  }

  // --- 4. Fungsi Logout Paksa (Token/Refresh Token Gagal) ---
  void _forceLogout() {
    _box.remove('token');
    _box.remove('refreshToken');
    _box.remove('userData');

    // Tampilkan snackbar dan arahkan ke halaman login
    Get.offAllNamed(Routes.LOGIN);
    Get.snackbar(
      'Sesi Berakhir',
      'Sesi Anda telah berakhir. Silakan masuk kembali.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}