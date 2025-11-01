// lib/modules/settings/views/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../presentation/themes/app_theme.dart';
import '../../home/controllers/home_controller.dart'; // Untuk akses data profil asli

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access Home Controller untuk data statis
    final HomeController homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Edit Profil'),
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                // 1. Avatar dan Image Picker
                _buildAvatarPicker(context, homeController),
                const SizedBox(height: 30),

                // 2. Field yang tidak bisa diedit (Nama & Email)
                _buildStaticField('Nama', homeController.userProfile.value?.name ?? 'N/A', Iconsax.user_outline),
                const SizedBox(height: 15),
                _buildStaticField('Email', homeController.userProfile.value?.email ?? 'N/A', Iconsax.sms_outline),
                const SizedBox(height: 30),

                // 3. Field yang bisa diedit
                _buildEditableTextField(
                  controller: controller.phoneC,
                  label: 'Nomor Telepon',
                  icon: Iconsax.call_outline,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // Gender Picker
                _buildGenderPicker(),
                const SizedBox(height: 20),

                // Tanggal Lahir Picker
                _buildDatePicker(context),
                const SizedBox(height: 20),

                // Alamat Lengkap
                _buildEditableTextField(
                  controller: controller.addressC,
                  label: 'Alamat Lengkap',
                  icon: Iconsax.location_outline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Provinsi
                _buildEditableTextField(
                  controller: controller.provinceC,
                  label: 'Provinsi',
                  icon: Iconsax.map_outline,
                ),
                const SizedBox(height: 20),

                // Kota
                _buildEditableTextField(
                  controller: controller.cityC,
                  label: 'Kota/Kabupaten',
                  icon: Iconsax.buildings_outline,
                ),
                const SizedBox(height: 20),

                // Kode Pos
                _buildEditableTextField(
                  controller: controller.postalCodeC,
                  label: 'Kode Pos',
                  icon: Iconsax.ruler_outline,
                  keyboardType: TextInputType.number,
                  validator: (val) => val != null && val.length < 5 ? 'Kode pos minimal 5 digit' : null,
                ),
                const SizedBox(height: 40),

                // 4. Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      'Simpan Perubahan',
                      style: Get.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildAvatarPicker(BuildContext context, HomeController homeController) {
    // Tentukan gambar yang akan ditampilkan
    ImageProvider? imageProvider;
    if (controller.pickedImage.value != null) {
      // Gambar baru dari picker
      imageProvider = FileImage(controller.pickedImage.value!);
    } else if (controller.currentImageUrl.value.isNotEmpty) {
      // Gambar dari API
      imageProvider = NetworkImage("https://api-travelers.karyadeveloperindonesia.com/${controller.currentImageUrl.value}");
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Get.theme.primaryColor.withOpacity(0.2),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(Iconsax.user_bold, size: 40, color: Get.theme.primaryColor)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Get.theme.scaffoldBackgroundColor, width: 2),
                ),
                child: const Icon(Iconsax.camera_outline, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Warna abu-abu pudar untuk field read-only
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong.';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Get.theme.colorScheme.surface,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      controller: controller.birthDateC,
      readOnly: true, // Tidak bisa diketik
      onTap: () => controller.selectBirthDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tanggal Lahir tidak boleh kosong.';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Tanggal Lahir (YYYY-MM-DD)',
        prefixIcon: Icon(Iconsax.calendar_edit_outline, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Get.theme.colorScheme.surface,
        suffixIcon: const Icon(Iconsax.arrow_down_1_outline, size: 18),
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8),
          child: Text('Jenis Kelamin', style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGenderOption('Laki-laki', 'L', Iconsax.man_outline),
            _buildGenderOption('Perempuan', 'P', Iconsax.woman_outline),
          ],
        ),
      ],
    ));
  }

  Widget _buildGenderOption(String label, String value, IconData icon) {
    final isSelected = controller.selectedGender.value == value;
    return GestureDetector(
      onTap: () => controller.selectedGender.value = value,
      child: Container(
        width: (Get.width - 60) / 2, // Lebar dibagi 2 minus padding
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: Get.textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppTheme.primaryColor : Colors.black87,
            )),
          ],
        ),
      ),
    );
  }
}