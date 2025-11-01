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
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          forceMaterialTransparency: true,
          foregroundColor: Get.theme.primaryColor,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/vly.png', width: size.width / 2, height: 100.0,),
                // Ikon/Judul Traveling
                const SizedBox(height: 20),
                Text(
                  'Buat Akun VLY TRIP',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rencanakan perjalanan anda dengan VlyTrip.', // "Masuk ke Akun Anda"
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyLarge?.copyWith(),
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
                        // 💥 Ganti Icons.person_outline menjadi Iconsax.user_outline
                        icon: Iconsax.user_outline,
                        validator: controller.nameValidator,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.emailC,
                        label: 'Email',
                        // 💥 Ganti Icons.email_outlined menjadi Iconsax.sms_outline
                        icon: Iconsax.sms_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.emailValidator,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.phoneC,
                        label: 'Nomor Telepon',
                        // 💥 Ganti Icons.phone_outlined menjadi Iconsax.phone_outline
                        icon: Iconsax.mobile_outline,
                        keyboardType: TextInputType.phone,
                        validator: controller.phoneValidator,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Obx(() => _buildPasswordField(
                        controller: controller.passwordC,
                        label: 'Password',
                        // Ikon password biasanya diatur di dalam _buildPasswordField,
                        // tapi kita bisa tambahkan ikon kekinian di sini (jika widget menerimanya)
                        // Saya asumsikan ikon 'lock' diatur secara default di dalam _buildPasswordField
                        isVisible: controller.isPasswordVisible.value,
                        toggleVisibility: controller.isPasswordVisible.toggle,
                        validator: controller.passwordValidator,
                      )),
                      const SizedBox(height: 16),

                      // Konfirmasi Password
                      Obx(() => _buildPasswordField(
                        controller: controller.confirmPasswordC,
                        label: 'Konfirmasi Password',
                        // Saya asumsikan ikon 'lock' diatur secara default di dalam _buildPasswordField
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50.0)),
                      value: controller.termsAccepted.value,
                      onChanged: (val) => controller.termsAccepted.value = val!,
                      activeColor: AppTheme.primaryColor,
                      side: BorderSide(width: 0.3),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),

                const SizedBox(height: 10),

                // Tombol Daftar
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.registerAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0.0,
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

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(color: Get.theme.dividerColor.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Atau Daftar Dengan', style: Get.textTheme.bodySmall),
                    ),
                    Expanded(child: Divider(color: Get.theme.dividerColor.withOpacity(0.2))),
                  ],
                ),

                const SizedBox(height: 20),

                // Opsi Social Signup
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
                      Text("Daftar dengan Google", style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                    ],
                  )),

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

  // Helper Widget untuk Password Field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
    final Color lightBorderColor = Colors.grey.shade300;
    final Color focusedBorderColor = Get.theme.primaryColor;
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      style: Get.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Iconsax.lock_outline, color: AppTheme.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Iconsax.eye_slash_outline : Iconsax.eye_outline),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: Get.theme.colorScheme.surface,
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