// lib/modules/auth/views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart'; // Package icons_plus
import 'package:travelers/config/routes/app_routes.dart';
import 'package:travelers/modules/auth/controllers/login_controller.dart';
import '../../../presentation/themes/app_theme.dart'; // Untuk warna

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8), // Biru gelap
                Get.theme.scaffoldBackgroundColor, // Warna latar belakang tema (gelap/terang)
              ],
              stops: const [0.0, 0.4],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),

                  // Logo/Ikon Bertema Traveling
                  Icon(
                    Clarity.plane_line,
                    size: 80,
                    color: Get.theme.colorScheme.onPrimary,
                  ),

                  const SizedBox(height: 16),

                  // Judul
                  Text(
                    'login_title'.tr, // "Masuk ke Akun Anda"
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // --- Form Login ---
                  Form(
                    key: controller.loginFormKey,
                    child: Column(
                      children: [
                        // Input Email
                        _buildTextField(
                          controller: controller.emailC,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.emailValidator,
                        ),
                        const SizedBox(height: 20),

                        // Input Password
                        Obx(() => _buildTextField(
                          controller: controller.passwordC,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: !controller.isPasswordVisible.value,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong.';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => controller.isPasswordVisible.toggle(),
                          ),
                        )),
                        const SizedBox(height: 30),

                        // Tombol Login
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.loginWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
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
                              'login_title'.tr, // Gunakan 'login_title'.tr jika tombolnya "Masuk"
                              style: Get.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Divider "Atau"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Get.theme.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('ATAU', style: Get.textTheme.bodySmall),
                      ),
                      Expanded(child: Divider(color: Get.theme.dividerColor)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Opsi Login Sosial Media ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Login dengan Google
                      _buildSocialButton(
                        icon: Iconsax.google_1_bold,
                        onPressed: controller.loginWithGoogle,
                      ),
                      // Login dengan Facebook
                      _buildSocialButton(
                        icon: Iconsax.facebook_bold,
                        onPressed: controller.loginWithFacebook,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Daftar
                  TextButton(
                    onPressed: () {
                      // TODO: Navigasi ke halaman daftar
                      Get.toNamed(Routes.REGISTER);
                    },
                    child: Text(
                      'Belum punya akun? Daftar Sekarang',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: Get.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Get.theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  // Helper Widget untuk Tombol Sosial Media
  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Get.theme.shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 30),
        padding: const EdgeInsets.all(15),
        onPressed: onPressed,
      ),
    );
  }
}