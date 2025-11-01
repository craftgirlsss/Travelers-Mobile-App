// lib/data/models/wishlist_response_model.dart

import 'wishlist_trip_model.dart';

class WishlistResponse {
  final bool status;
  final String message;
  final List<WishlistTripModel> response;

  WishlistResponse({
    required this.status,
    required this.message,
    required this.response,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    List<WishlistTripModel> wishlistTrips = [];

    if (json['response'] is List) {
      wishlistTrips = (json['response'] as List)
          .map((item) => WishlistTripModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return WishlistResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      response: wishlistTrips,
    );
  }
}