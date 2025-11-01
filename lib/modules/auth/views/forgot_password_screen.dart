import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:travelers/modules/auth/controllers/forgot_password_controller.dart';
import 'package:travelers/presentation/themes/app_theme.dart'; // Untuk warna AppTheme

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  // Helper Widget untuk Input Field (Disalin dari LoginScreen)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
    final Color lightBorderColor = Colors.grey.shade300;
    final Color focusedBorderColor = Get.theme.primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: Get.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: lightBorderColor.withOpacity(0.5)),
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
    final size = MediaQuery.of(context).size;
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

                // Logo/Ikon Bertema Traveling
                Center(
                  child: Image.asset('assets/images/vly.png', width: size.width / 2, height: 100.0),
                ),

                const SizedBox(height: 32),

                // Judul
                Text(
                  'Lupa Kata Sandi?',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                Text(
                  'Masukkan email Anda. Kami akan mengirimkan kode verifikasi (OTP) untuk mereset kata sandi Anda.',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 40),

                // --- Form Email ---
                Form(
                  key: controller.forgotPasswordFormKey,
                  child: _buildTextField(
                    controller: controller.emailC,
                    label: 'Email',
                    icon: Iconsax.sms_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.emailValidator,
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Kirim Permintaan Reset
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.sendResetRequest, // Panggil fungsi API
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
                      'Kirim Permintaan',
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
