import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:travelers/modules/auth/controllers/otp_controller.dart';
import 'package:travelers/presentation/themes/app_theme.dart';

class OtpVerificationScreen extends GetView<OtpController> {
  const OtpVerificationScreen({super.key});

  // Helper Widget untuk Input Field (Diadaptasi untuk OTP)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
    final Color lightBorderColor = Colors.grey.shade300;
    final Color focusedBorderColor = Get.theme.primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: Get.textTheme.headlineSmall?.copyWith(letterSpacing: 10, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        counterText: "", // Menyembunyikan counter max length
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),

        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: lightBorderColor),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Bootstrap.arrow_left_short, color: Colors.black, size: 30),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Ikon Verifikasi
                Center(
                  child: Icon(
                      Bootstrap.patch_check_fill,
                      size: 80,
                      color: Get.theme.primaryColor
                  ),
                ),

                const SizedBox(height: 32),

                // Judul
                Text(
                  'Verifikasi Kode OTP',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                Text(
                  'Kami telah mengirimkan kode 6 digit ke email ${controller.userEmail}. Masukkan kode di bawah ini.',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 40),

                // --- Form OTP Input ---
                Form(
                  key: controller.otpFormKey,
                  child: _buildTextField(
                    controller: controller.otpC,
                    label: 'Kode OTP',
                    icon: Icons.numbers_rounded, // Ikon angka
                    keyboardType: TextInputType.number,
                    validator: controller.otpValidator,
                    maxLength: 6, // Kode OTP 6 digit
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Verifikasi
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.verifyOtp, // Panggil fungsi API verifikasi
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Verifikasi dan Lanjutkan',
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ),

                const SizedBox(height: 20),

                // Tombol Resend OTP
                Obx(() => TextButton(
                  onPressed: controller.resendSeconds.value == 0
                      ? controller.resendOtp
                      : null,
                  child: Text(
                    controller.timerText,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: controller.resendSeconds.value == 0
                          ? AppTheme.primaryColor
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}