class VehicleModel {
  final String? name;
  final int? capacity;
  final String? type;
  final String? photoPath;

  VehicleModel({
    this.name,
    this.capacity,
    this.type,
    this.photoPath,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk konversi aman ke int (jika diperlukan)
    int? safeParseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return VehicleModel(
      // Menggunakan 'as String?' untuk menerima null
      name: json['name'] as String?,
      capacity: safeParseIntNullable(json['capacity']),
      type: json['type'] as String?,
      photoPath: json['photo_path'] as String?,
    );
  }
}