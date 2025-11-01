// lib/data/repositories/user_repository.dart (Buat file ini jika belum ada)
import 'dart:convert';
import 'package:get/get.dart';

import '../providers/api_provider.dart';

class UserRepository {
  final ApiService _apiService = Get.find<ApiService>();

  final String _fcmApiEndpoint = '/user/fcm-token';

  Future<bool> updateFCMToken({
    required String fcmToken,
    required String platform,
    required String deviceName,
    required String deviceModel,
  }) async {
    try {
      final body = {
        'fcm_token': fcmToken,
        'platform': platform,
        'device_name': deviceName,
        'device_model': deviceModel,
      };

      final response = await _apiService.post(_fcmApiEndpoint, body: jsonEncode(body));
      Get.log('Sending FCM Token: ${jsonEncode(body)}');
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      Get.log('Error updating FCM Token: $e');
      return false;
    }
  }
}