// lib/data/repositories/trip_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../models/booking_model.dart';
import '../models/booking_response.dart';
import '../models/claimed_voucher_model.dart';
import '../models/international_trip_model.dart';
import '../models/profile_model.dart';
import '../models/trip_detail_model.dart';
import '../models/trip_model.dart';
import '../models/voucher_model.dart';
import '../providers/api_provider.dart';
import '../models/wishlist_trip_model.dart'; // Import model baru
import '../models/wishlist_response_model.dart';
import 'package:http/http.dart' as http;

class TripRepository extends GetConnect {
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
      print(response.body);

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
      print(response.body);

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

  // --- 4. Ambil Detail Trip Authenticated ---
  Future<TripDetailModel?> fetchTripDetailAuthenticated(String uuid) async {
    try {
      final response = await _apiService.get('/trip/$uuid/auth');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final Map<String, dynamic> fullData = {
            ...(responseData['data'] as Map<String, dynamic>),
            'booking': responseData['booking']
          };
          return TripDetailModel.fromJson(fullData);
        }
      }

      // Jika status bukan 200 atau 'success', log pesan error dari API
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Data tidak tersedia.';
      Get.log("Gagal memuat detail trip: ${response.statusCode}. Pesan: $errorMessage");
      return null;

    } catch (e) {
      Get.log('Error saat fetchTripDetailAuthenticated: $e');
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

      // 💥 PERBAIKAN: Hapus kurung kurawal ekstra pada string interpolation
      final fullPath = "$path?location=$location";

      Get.log("Mencoba memanggil API: $fullPath"); // Tambahkan log URL lengkap

      // Panggil API dengan query parameter 'location'
      final response = await _apiService.get(fullPath);
      Get.log("Response Body dari $fullPath: ${response.body}"); // Log response body dengan jelas

      if (response.statusCode == 200) {
        // Asumsi _parseTripResponse menerima body string dan mengembalikan List<TripModel>
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

  // --- 7. Ambil Daftar Wishlist ---
  // Mengembalikan List<WishlistTripModel>
  Future<List<WishlistTripModel>> fetchWishlist() async {
    try {
      final response = await _apiService.get('/wishlist');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parsing menggunakan model response baru
        final wishlistResponse = WishlistResponse.fromJson(data);

        if (wishlistResponse.status == true) {
          return wishlistResponse.response;
        }
      }

      Get.log("Gagal memuat wishlist: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat fetchWishlist: $e');
      return [];
    }
  }

  // --- 8. Ambil Riwayat Pemesanan (Booking) ---
  Future<List<BookingModel>> fetchBookingHistory() async {
    try {
      final response = await _apiService.get('/booking');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => BookingModel.fromJson(item))
              .toList();
        }
      }

      Get.log("Gagal memuat histori pemesanan: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat fetchBookingHistory: $e');
      return [];
    }
  }

  // --- 9. Update Data Profil Pengguna (Edit Profile) ---
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String gender,
    required String address,
    required String birthDate,
    required String province,
    required String city,
    required String postalCode,
    File? profilePictureFile, // File opsional untuk diunggah
  }) async {
    try {
      const path = '/client/profile';

      // Menggunakan MultipartRequest karena ada file upload
      final request = http.MultipartRequest('POST', Uri.parse(_apiService.baseUrl + path));

      // Ambil token dari GetStorage/ApiService
      final token = await _apiService.box.read('token');
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        // Tidak perlu 'Content-Type': 'multipart/form-data' karena Request otomatis menambahkannya
      });

      // Tambahkan field data ke request
      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['gender'] = gender;
      request.fields['address'] = address;
      request.fields['birth_date'] = birthDate;
      request.fields['province'] = province;
      request.fields['city'] = city;
      request.fields['postal_code'] = postalCode;

      // Tambahkan file jika ada
      if (profilePictureFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture', // Pastikan key ini sesuai dengan body API
            profilePictureFile.path,
          ),
        );
      }

      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Get.log("Update profile berhasil: ${responseData['message']}");
        // Refresh token dan/atau user data jika API mengembalikannya
        return true;
      }

      Get.log("Gagal update profile: ${response.statusCode} - ${responseData['message']}");
      return false;

    } catch (e) {
      Get.log('Error saat updateProfile: $e');
      return false;
    }
  }


  // --- 10. Klaim Voucher ---
  // Mengembalikan Map yang berisi hasil (success/message/uuid)
  Future<Map<String, dynamic>> claimVoucher(String voucherUuid) async {
    print(voucherUuid);
    try {
      final response = await _apiService.post(
        '/vouchers/claim',
        body: jsonEncode({
          'voucher_uuid': voucherUuid,
        }),
      );

      final responseData = jsonDecode(response.body);

      // Asumsi status code 200 untuk sukses atau error validasi
      if (response.statusCode == 200) {
        // Asumsi respons sukses: 'status': 'success'
        if (responseData['status'] == 'success') {
          return {
            'success': true,
            'message': responseData['message'],
            'voucherUuid': responseData['voucher_uuid'],
          };
        }
        // Handle error yang dikirim dengan status 200
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengklaim voucher (API Error).',
        };
      }

      // Handle error server (4xx, 5xx)
      Get.log("Gagal klaim voucher: ${response.statusCode}");
      return {
        'success': false,
        'message': 'Gagal klaim voucher. Kode status: ${response.statusCode}',
      };

    } catch (e) {
      Get.log('Error saat claimVoucher: $e');
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server.',
      };
    }
  }


  // --- 11. Ambil Daftar Voucher yang Sudah Diklaim ---
  /// Mengembalikan Set<String> yang berisi UUID voucher yang sudah diklaim.
  Future<Set<String>> fetchClaimedVouchers() async {
    try {
      final response = await _apiService.get('/vouchers/claimed');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] is List) {
          // Kita hanya perlu UUID-nya saja
          final Set<String> claimedUuids = {};
          for (var item in (data['data'] as List)) {
            if (item['voucher_uuid'] != null) {
              claimedUuids.add(item['voucher_uuid'] as String);
            }
          }
          return claimedUuids;
        }
      }

      Get.log("Gagal memuat voucher diklaim: ${response.statusCode}");
      return {};

    } catch (e) {
      Get.log('Error saat fetchClaimedVouchers: $e');
      return {};
    }
  }


  // --- 11. Ambil Daftar Voucher yang Sudah Diklaim (Data Penuh) ---
  /// Mengembalikan List<ClaimedVoucherModel>.
  Future<List<ClaimedVoucherModel>> getClaimedVoucherData() async {
    try {
      final response = await _apiService.get('/vouchers/claimed');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => ClaimedVoucherModel.fromJson(item))
              .toList();
        }
      }

      Get.log("Gagal memuat voucher diklaim data: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat getClaimedVoucherData: $e');
      return [];
    }
  }

  // 💥 FUNGSI BARU: Mendapatkan Daftar Trip Internasional
  Future<List<InternationalTripModel>> fetchInternationalTrips() async {
    try {
      final response = await _apiService.get('/trips/international');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] is List) {
          return (data['data'] as List)
          // 💥 MAP KE MODEL BARU
              .map((item) => InternationalTripModel.fromJson(item))
              .toList();
        }
      }

      Get.log("Gagal memuat trip internasional: ${response.statusCode}");
      return [];

    } catch (e) {
      Get.log('Error saat fetchInternationalTrips: $e');
      return [];
    }
  }

  // FUNGSI API BARU: Membuat Booking (Menggunakan JSON Body)
  Future<BookingResponse> createBooking({
    required String tripUuid,
    required int numOfPeople,
  }) async {
    try {
      // ... (persiapan body)
      final body = {
        'trip_uuid': tripUuid,
        'num_of_people': numOfPeople.toString(),
      };

      final response = await _apiService.post('/booking', body: body);

      // 💥 PERBAIKAN: Terima status code 200 atau 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          return BookingResponse.fromJson(data);

        } else {
          // Respons sukses (200/201) tapi status internal adalah kegagalan
          return BookingResponse(success: false, message: data['message'] ?? 'Booking failed (API status fail)');
        }
      } else {
        // Tangani status error HTTP (misal 401, 500)
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Booking failed with status ${response.statusCode}';

        return BookingResponse(success: false, message: errorMessage);
      }

    } catch (e) {
      Get.log("ERROR CREATE BOOKING: $e");
      return BookingResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }
}