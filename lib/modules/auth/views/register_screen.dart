// lib/modules/auth/views/register_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../config/routes/app_routes.dart';
import '../controllers/register_controller.dart';
import '../../../presentation/themes/app_theme.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Daftar Akun Baru'.tr),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Get.theme.primaryColor,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Ikon/Judul Traveling
                Text(
                  'Buat Akun Travelers',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rencanakan perjalanan Anda bersama Travelers.',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),

                const SizedBox(height: 40),

                // --- Form Registrasi ---
                Form(
                  key: controller.registerFormKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: controller.nameC,
                        label: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        validator: controller.nameValidator,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.emailC,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.emailValidator,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.phoneC,
                        label: 'Nomor Telepon',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: controller.phoneValidator,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Obx(() => _buildPasswordField(
                        controller: controller.passwordC,
                        label: 'Password',
                        isVisible: controller.isPasswordVisible.value,
                        toggleVisibility: controller.isPasswordVisible.toggle,
                        validator: controller.passwordValidator,
                      )),
                      const SizedBox(height: 16),

                      // Konfirmasi Password
                      Obx(() => _buildPasswordField(
                        controller: controller.confirmPasswordC,
                        label: 'Konfirmasi Password',
                        isVisible: controller.isConfirmPasswordVisible.value,
                        toggleVisibility: controller.isConfirmPasswordVisible.toggle,
                        validator: controller.confirmPasswordValidator,
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Syarat & Ketentuan Checkbox
                Obx(() => Row(
                  children: [
                    Checkbox(
                      value: controller.termsAccepted.value,
                      onChanged: (val) => controller.termsAccepted.value = val!,
                      activeColor: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showTermsModal(context),
                        child: RichText(
                          text: TextSpan(
                            style: Get.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Saya menyetujui ',
                                style: TextStyle(color: Get.theme.textTheme.bodyMedium?.color),
                              ),
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),

                const SizedBox(height: 25),

                // Tombol Daftar
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.registerAccount,
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    'Daftar Sekarang',
                    style: Get.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )),

                const SizedBox(height: 40),

                // Divider "Atau"
                Row(
                  children: [
                    Expanded(child: Divider(color: Get.theme.dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ATAU DAFTAR DENGAN', style: Get.textTheme.bodySmall),
                    ),
                    Expanded(child: Divider(color: Get.theme.dividerColor)),
                  ],
                ),

                const SizedBox(height: 30),

                // Opsi Social Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      icon: Bootstrap.google,
                      onPressed: () => controller.socialSignup('Google'),
                    ),
                    _buildSocialButton(
                      icon: FontAwesome.facebook_brand,
                      onPressed: () => controller.socialSignup('Facebook'),
                    ),
                    _buildSocialButton(
                      icon: FontAwesome.tiktok_brand,
                      onPressed: () => controller.socialSignup('Tiktok'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Kembali ke Login
                TextButton(
                  onPressed: () => Get.offNamed(Routes.LOGIN),
                  child: Text(
                    'Sudah punya akun? Masuk',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Input Field Umum
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: Get.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
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

  // Helper Widget untuk Password Field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      style: Get.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
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

  // Modal Bottom Sheet untuk Syarat & Ketentuan
  void _showTermsModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.75, // 75% dari tinggi layar
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Syarat & Ketentuan Travelers',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  // Isi dummy syarat dan ketentuan
                  "Selamat datang di Travelers! Dengan mendaftar, Anda menyetujui bahwa Anda adalah orang yang nyata dan bukan bot. Kami akan menggunakan data Anda hanya untuk tujuan pemesanan tiket dan mengirimkan penawaran spesial tentang perjalanan ke tempat-tempat keren. Kami tidak bertanggung jawab jika Anda jatuh cinta dengan pemandu wisata Anda, atau jika penerbangan Anda dibatalkan karena cuaca ekstrem (kecuali jika kami yang menyebabkan cuaca ekstrem itu). Pastikan password Anda sekuat ikatan Anda dengan kopi pagi! Jika ada pertanyaan, jangan ragu hubungi kami. Selamat bertualang! \n\n" * 5,
                  style: Get.textTheme.bodyMedium,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.termsAccepted.value = true;
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Setuju & Tutup', style: Get.textTheme.titleMedium?.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
    );
  }
}