import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:travelers/modules/auth/controllers/reset_password_controller.dart';
import 'package:travelers/presentation/themes/app_theme.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  // Helper Widget untuk Input Field (Disalin dari LoginScreen)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
    final Color lightBorderColor = Colors.grey.shade300;
    final Color focusedBorderColor = Get.theme.primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: Get.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: suffixIcon,
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

                // Ikon Gembok
                Center(
                  child: Icon(
                      Bootstrap.lock_fill,
                      size: 80,
                      color: Get.theme.primaryColor.withOpacity(0.8)
                  ),
                ),

                const SizedBox(height: 32),

                // Judul
                Text(
                  'Atur Kata Sandi Baru',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                Text(
                  'Silakan masukkan kata sandi baru yang ingin Anda gunakan. Pastikan mudah diingat.',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 40),

                // --- Form Reset Password ---
                Form(
                  key: controller.resetPasswordFormKey,
                  child: Column(
                    children: [
                      // Input Kata Sandi Baru
                      Obx(() => _buildTextField(
                        controller: controller.passwordC,
                        label: 'Kata Sandi Baru',
                        icon: Bootstrap.key,
                        obscureText: !controller.isPasswordVisible.value,
                        keyboardType: TextInputType.text,
                        validator: controller.passwordValidator,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value ? Bootstrap.eye_slash : Bootstrap.eye,
                            color: Colors.black54,
                          ),
                          onPressed: () => controller.isPasswordVisible.toggle(),
                        ),
                      )),
                      const SizedBox(height: 20),

                      // Input Konfirmasi Kata Sandi
                      Obx(() => _buildTextField(
                        controller: controller.confirmPasswordC,
                        label: 'Konfirmasi Kata Sandi Baru',
                        icon: Bootstrap.key_fill,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        keyboardType: TextInputType.text,
                        validator: controller.confirmPasswordValidator,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value ? Bootstrap.eye_slash : Bootstrap.eye,
                            color: Colors.black54,
                          ),
                          onPressed: () => controller.isConfirmPasswordVisible.toggle(),
                        ),
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Simpan Kata Sandi Baru
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.resetPassword, // Panggil fungsi API reset
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
                      'Simpan Kata Sandi Baru',
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