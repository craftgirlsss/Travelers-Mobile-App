// lib/modules/settings/controllers/edit_profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../home/controllers/home_controller.dart'; // Untuk mendapatkan data profil awal

class EditProfileController extends GetxController {
  final TripRepository _tripRepository = Get.find<TripRepository>();
  final HomeController _homeController = Get.find<HomeController>();

  // Form State
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  // Controllers untuk field yang bisa diedit
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final birthDateC = TextEditingController(); // Akan disimpan sebagai String YYYY-MM-DD
  final provinceC = TextEditingController();
  final cityC = TextEditingController();
  final postalCodeC = TextEditingController();

  // State untuk Gender
  final RxString selectedGender = 'L'.obs; // Default: Laki-laki ('L')

  // State untuk Profile Picture
  final Rx<File?> pickedImage = Rx<File?>(null); // File yang baru dipilih
  final RxString currentImageUrl = ''.obs; // URL gambar yang sudah ada

  @override
  void onInit() {
    // Isi data awal saat controller diinisialisasi
    _loadInitialData();
    super.onInit();
  }

  void _loadInitialData() {
    final profile = _homeController.userProfile.value;
    if (profile != null) {
      phoneC.text = profile.phone ?? '';
      addressC.text = profile.address ?? '';
      birthDateC.text = profile.birthDate ?? '';
      provinceC.text = profile.province ?? '';
      cityC.text = profile.city ?? '';
      postalCodeC.text = profile.postalCode ?? '';
      selectedGender.value = profile.gender ?? 'L';
      currentImageUrl.value = profile.detailPictureUrl ?? '';
    }
  }

  // --- Picker Foto ---
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
    }
  }

  // --- Date Picker ---
  Future<void> selectBirthDate(BuildContext context) async {
    DateTime? initialDate;
    try {
      initialDate = DateTime.parse(birthDateC.text);
    } catch (e) {
      initialDate = DateTime(2000); // Default jika parsing gagal
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthDateC.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // --- Fungsi Update Profil ---
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    // Ambil nama dari Home Controller (karena tidak diedit, hanya dikirim)
    final name = _homeController.userProfile.value?.name ?? '';

    final success = await _tripRepository.updateProfile(
      name: name,
      phone: phoneC.text,
      gender: selectedGender.value,
      address: addressC.text,
      birthDate: birthDateC.text,
      province: provinceC.text,
      city: cityC.text,
      postalCode: postalCodeC.text,
      profilePictureFile: pickedImage.value,
    );

    print("INI RESPONSE updatProfile() => $success");

    isLoading.value = false;

    if (success) {
      // 1. Refresh data profil di HomeController setelah update
      await _tripRepository.fetchUserProfile();
      Get.back();
      Get.snackbar('Sukses', 'Profil berhasil diperbarui!', backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Gagal', 'Gagal memperbarui profil. Coba lagi.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    phoneC.dispose();
    addressC.dispose();
    birthDateC.dispose();
    provinceC.dispose();
    cityC.dispose();
    postalCodeC.dispose();
    super.onClose();
  }
}