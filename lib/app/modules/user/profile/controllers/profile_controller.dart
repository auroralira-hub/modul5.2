import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_3/app/data/models.dart';

class ProfileController extends GetxController {
  final User user;
  
  ProfileController({required this.user});
  
  // Observables
  final isLoading = false.obs;
  
  void logout() {
    Get.defaultDialog(
      title: 'Konfirmasi Logout',
      middleText: 'Apakah Anda yakin ingin keluar?',
      textConfirm: 'Ya',
      textCancel: 'Tidak',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.offAllNamed('/auth');
      },
    );
  }
  
  void editProfile() {
    Get.snackbar(
      'Edit Profil',
      'Fitur edit profil akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void changePassword() {
    Get.snackbar(
      'Ubah Password',
      'Fitur ubah password akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
