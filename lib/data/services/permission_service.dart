// lib/data/services/permission_service.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends GetxService {
  final List<Permission> _requiredPermissions = [
    Permission.camera,
    Permission.location,
    Permission.notification,
    Permission.storage, // Storage masih relevan untuk Android lama
  ];

  @override
  void onInit() {
    super.onInit();
  }

  // --- 1. Meminta Izin Secara Massal (Untuk Splash/Onboarding) ---
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> statuses =
    await _requiredPermissions.request();

    _handlePermissionResults(statuses);
    return statuses;
  }

  // --- 2. Fungsi Khusus untuk Meminta Izin Lokasi (Jika butuh spesifik) ---
  Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status;
  }

  // --- 3. Memeriksa Status Izin Khusus ---
  Future<bool> checkPermissionStatus(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // --- 4. Fungsi Helper untuk Menangani Izin yang Ditolak Permanen ---
  void _handlePermissionResults(Map<Permission, PermissionStatus> statuses) {
    bool needsSettings = false;
    statuses.forEach((permission, status) {
      if (status.isPermanentlyDenied) {
        needsSettings = true;
      }
    });

    if (needsSettings) {
      // Tampilkan dialog yang meminta user pergi ke Settings
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    Get.defaultDialog(
      title: "Izin Diperlukan",
      middleText: "Beberapa izin penting ditolak secara permanen. Anda perlu mengaktifkannya di Pengaturan Aplikasi untuk melanjutkan.",
      textConfirm: "Buka Pengaturan",
      textCancel: "Nanti",
      confirmTextColor: Colors.white,
      onConfirm: () {
        openAppSettings(); // Fungsi dari permission_handler
        Get.back();
      },
      onCancel: () {
        // Logika jika user menolak membuka settings, misalnya membatasi fitur
        Get.back();
      },
    );
  }
}