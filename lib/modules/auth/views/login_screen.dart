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
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                // Logo/Ikon Bertema Traveling
                Image.asset('assets/images/vly.png', width: size.width / 2, height: 100.0,),

                const SizedBox(height: 16),

                // Judul
                Text(
                  'Masuk ke akun Anda untuk mencari layanan trip Anda.', // "Masuk ke Akun Anda"
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyLarge?.copyWith(),
                ),
                const SizedBox(height: 80),

                // --- Form Login ---
                Column(
                  children: [
                    // Input Email
                    _buildTextField(
                      controller: controller.emailC,
                      label: 'Email',
                      icon: Iconsax.sms_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.emailValidator,
                    ),
                    const SizedBox(height: 20),

                    // Input Password
                    Obx(() => _buildTextField(
                      controller: controller.passwordC,
                      label: 'Password',
                      icon: Iconsax.lock_outline,
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
                          controller.isPasswordVisible.value ? Iconsax.eye_slash_outline : Iconsax.eye_outline
                        ),
                        onPressed: () => controller.isPasswordVisible.toggle(),
                      ),
                    )),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD), child: Text('Lupa Password?', style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)))
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.loginWithEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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


                const SizedBox(height: 20),

                // Divider "Atau"
                Row(
                  children: [
                    Expanded(child: Divider(color: Get.theme.dividerColor.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ATAU', style: Get.textTheme.bodySmall),
                    ),
                    Expanded(child: Divider(color: Get.theme.dividerColor.withOpacity(0.2))),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.google_1_bold, color: AppTheme.primaryColor),
                    const SizedBox(width: 5.0),
                    Text("Login dengan Google", style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                  ],
                )),

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
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
    // Warna terang untuk border yang tidak fokus/default
    final Color lightBorderColor = Colors.grey.shade300;
    // Warna untuk border saat fokus (gunakan warna utama theme)
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

        // 💥 1. BORDER UTAMA SAAT TIDAK FOKUS (DEFAULT)
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: lightBorderColor), // Menggunakan warna terang
        ),

        // 💥 2. BORDER SAAT FOKUS
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: focusedBorderColor, width: 2.0), // Lebih tebal dan berwarna saat fokus
        ),

        // 3. BORDER UMUM (Fallback)
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: lightBorderColor),
        ),

        // 4. BORDER SAAT DISABLE
        disabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: lightBorderColor.withOpacity(0.5)),
        ),

        // 5. BORDER SAAT ERROR
        errorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.red),
        ),

        // 6. BORDER SAAT FOKUS DAN ERROR
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
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