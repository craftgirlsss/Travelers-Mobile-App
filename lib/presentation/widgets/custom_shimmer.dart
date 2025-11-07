import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CustomShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8.0, // Default border radius
  });

  @override
  Widget build(BuildContext context) {
    // 1. Definisikan Warna Shimmer
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    // 2. Gunakan Shimmer.fromColors
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1000), // Kecepatan shimmer
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor, // Warna ini akan di-override oleh efek shimmer
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}