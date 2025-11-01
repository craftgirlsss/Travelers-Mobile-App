import 'package:travelers/data/models/tour_guide_model.dart';
import 'package:travelers/data/models/trip_model.dart';
import 'package:travelers/data/models/vehicle_model.dart';
import 'accommodation_model.dart';
import 'booking_status_model.dart';

class ImageModel {
  final String imageUrl;
  final int isMain;
  ImageModel.fromJson(Map<String, dynamic> json) :
        imageUrl = json['image_url'],
        isMain = json['is_main'];
}

class TripDetailModel {
  final String uuid;
  final String title;
  final String description;
  final String duration;
  final String location;
  final String gatheringPointName;
  final String gatheringPointUrl;
  final int price;
  final int discountPrice;
  final int maxParticipants;
  final int bookedParticipants;
  final int remainingSeats;
  final String startDate;
  final String endDate;
  final String departureTime;
  final String returnTime;

  // Asumsi fields dari UI
  final double distanceKm;
  final double rating;
  final double tempC;

  final ProviderModel provider;
  final List<ImageModel> images;
  final BookingStatusModel? bookingStatus; // Properti kunci untuk update state

  final AccommodationModel? accommodation;
  final TourGuideModel? tourGuide;
  final VehicleModel? vehicle;


  TripDetailModel({
    required this.uuid,
    required this.title,
    required this.description,
    required this.duration,
    required this.location,
    required this.gatheringPointName,
    required this.gatheringPointUrl,
    required this.price,
    required this.discountPrice,
    required this.maxParticipants,
    required this.bookedParticipants,
    required this.remainingSeats,
    required this.startDate,
    required this.endDate,
    required this.departureTime,
    required this.returnTime,

    this.distanceKm = 0.0,
    this.rating = 0.0,
    this.tempC = 0.0,

    required this.provider,
    required this.images,
    this.bookingStatus,
    this.accommodation,
    this.tourGuide,
    this.vehicle,
  });


  factory TripDetailModel.fromJson(Map<String, dynamic> json) {
    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Parsing data bersarang
    final bookingData = json['booking'] as Map<String, dynamic>?;
    final providerData = json['provider'] as Map<String, dynamic>;
    final List<dynamic> imagesList = json['images'] as List<dynamic>;

    final vehicleData = json['vehicle'] as Map<String, dynamic>?;

    final accommodationData = json['accommodation'] as Map<String, dynamic>?;
    final tourGuideData = json['tour_guide'] as Map<String, dynamic>?;

    return TripDetailModel(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] as String,
      location: json['location'] as String,
      gatheringPointName: json['gathering_point_name'] as String,
      gatheringPointUrl: json['gathering_point_url'] as String,
      price: safeParseInt(json['price']),
      discountPrice: safeParseInt(json['discount_price']),
      maxParticipants: safeParseInt(json['max_participants']),
      bookedParticipants: safeParseInt(json['booked_participants']),
      remainingSeats: safeParseInt(json['remaining_seats']),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      departureTime: json['departure_time'] as String,
      returnTime: json['return_time'] as String,

      distanceKm: safeParseDouble(json['distance_km'] ?? 0.0),
      rating: safeParseDouble(json['rating'] ?? 0.0),
      tempC: safeParseDouble(json['temp_c'] ?? 0.0),

      provider: ProviderModel.fromJson(providerData),
      images: imagesList.map((i) => ImageModel.fromJson(i as Map<String, dynamic>)).toList(),

      bookingStatus: bookingData != null
          ? BookingStatusModel.fromJson(bookingData)
          : null,

      accommodation: accommodationData != null
          ? AccommodationModel.fromJson(accommodationData)
          : null,
      tourGuide: tourGuideData != null
          ? TourGuideModel.fromJson(tourGuideData)
          : null,

      vehicle: vehicleData != null
          ? VehicleModel.fromJson(vehicleData)
          : null,
    );
  }

  // 💥 IMPLEMENTASI FUNGSI COPYWITH
  TripDetailModel copyWith({
    String? uuid,
    String? title,
    String? description,
    String? duration,
    String? location,
    String? gatheringPointName,
    String? gatheringPointUrl,
    int? price,
    int? discountPrice,
    int? maxParticipants,
    int? bookedParticipants,
    int? remainingSeats,
    String? startDate,
    String? endDate,
    String? departureTime,
    String? returnTime,

    double? distanceKm,
    double? rating,
    double? tempC,

    ProviderModel? provider,
    List<ImageModel>? images,
    BookingStatusModel? bookingStatus, // Properti kunci yang diubah
    AccommodationModel? accommodation,
    TourGuideModel? tourGuide,
    VehicleModel? vehicle,
  }) {
    return TripDetailModel(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      gatheringPointName: gatheringPointName ?? this.gatheringPointName,
      gatheringPointUrl: gatheringPointUrl ?? this.gatheringPointUrl,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      bookedParticipants: bookedParticipants ?? this.bookedParticipants,
      remainingSeats: remainingSeats ?? this.remainingSeats,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      departureTime: departureTime ?? this.departureTime,
      returnTime: returnTime ?? this.returnTime,

      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      tempC: tempC ?? this.tempC,

      provider: provider ?? this.provider,
      images: images ?? this.images,
      bookingStatus: bookingStatus ?? this.bookingStatus, // Nilai Booking Status yang baru
      accommodation: accommodation ?? this.accommodation,
      tourGuide: tourGuide ?? this.tourGuide,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}