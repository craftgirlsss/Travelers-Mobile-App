// lib/data/repositories/trip_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import '../models/profile_model.dart';
import '../models/trip_detail_model.dart';
import '../models/trip_model.dart';
import '../models/voucher_model.dart';
import '../providers/api_provider.dart';

class TripRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Endpoint
  static const String _profileEndpoint = '/client/profile';
  static const String _tripsEndpoint = '/trips';

  // --- Fungsi Helper untuk Parsing Trip ---
  List<TripModel> _parseTripResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody);

      // Memastikan respons API memiliki format {"status": "success", "data": [...]}
      if (data['status'] == 'success' && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => TripModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      Get.log('Error parsing trip data: $e');
      return [];
    }
  }

  // --- 1. Ambil Data Profil Pengguna ---
  Future<ProfileModel?> fetchUserProfile() async {
    try {
      final response = await _apiService.get(_profileEndpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return ProfileModel.fromJson(data['data']);
        }
      }

      Get.log("Gagal memuat profil: ${response.statusCode}");
      return null;

    } catch (e) {
      Get.log('Error saat fetchUserProfile: $e');
      return null;
    }
  }

  // --- 2. Ambil Semua Daftar Trip ---
  Future<List<TripModel>> fetchAllTrips() async {
    try {
      final response = await _apiService.get(_tripsEndpoint);

      if (response.statusCode == 200) {
        return _parseTripResponse(response.body); // Menggunakan helper
      }

      Get.log("Gagal memuat trips: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat fetchAllTrips: $e');
      return [];
    }
  }

  // --- 3. Ambil Detail Trip ---
  Future<TripDetailModel?> fetchTripDetail(String uuid) async {
    try {
      final response = await _apiService.get('/trips/$uuid');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return TripDetailModel.fromJson(data['data']);
        }
      }

      Get.log("Gagal memuat detail trip: ${response.statusCode}");
      return null;

    } catch (e) {
      Get.log('Error saat fetchTripDetail: $e');
      return null;
    }
  }

  // --- 4. Ambil Daftar Voucher ---
  Future<List<VoucherModel>> fetchVouchers() async {
    try {
      final response = await _apiService.get('/vouchers');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Perhatikan: Respons Voucher menggunakan "status: true" dan "response: List"
        if (data['status'] == true && data['response'] is List) {
          return (data['response'] as List)
              .map((json) => VoucherModel.fromJson(json))
              .toList();
        }
      }

      Get.log("Gagal memuat voucher: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat fetchVouchers: $e');
      return [];
    }
  }

  // --- 5. Get Trips By Destination Location ---
  Future<List<TripModel>> searchTripsByDestination(String location) async {
    try {
      const path = '/trips/search';

      // Panggil API dengan query parameter 'location'
      final response = await _apiService.get("${path}?location=$location}");

      if (response.statusCode == 200) {
        return _parseTripResponse(response.body);
      }

      Get.log("Gagal memuat trip destinasi: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat searchTripsByDestination: $e');
      return [];
    }
  }

  // --- 6. Get Trips By Gathering Point ---
  Future<List<TripModel>> searchTripsByGatheringPoint(String query) async {
    try {
      const path = '/trips/search-gathering-point';

      // Panggil API dengan query parameter 'q'
      final response = await _apiService.get("${path}?q=$query}");

      if (response.statusCode == 200) {
        return _parseTripResponse(response.body);
      }

      Get.log("Gagal memuat trip titik kumpul: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat searchTripsByGatheringPoint: $e');
      return [];
    }
  }
}