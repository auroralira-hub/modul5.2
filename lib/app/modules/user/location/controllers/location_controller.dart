import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_3/app/data/models.dart';

class LocationController extends GetxController {
  // Controllers
  final searchController = TextEditingController();
  
  // Observables
  final searchQuery = ''.obs;
  final selectedService = 'Semua'.obs;
  
  final User user;
  
  LocationController({required this.user});
  
  // Services
  final List<String> services = [
    'Semua',
    'Psikolog',
    'Psikiater',
    'Konseling',
    'Hotline'
  ];
  
  // Locations data
  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Klinik Psikologi Universitas',
      'type': 'Psikolog',
      'address': 'Gedung Rektorat Lt.3, Kampus',
      'phone': '(021) 1234-5678',
      'hours': 'Senin-Jumat 08:00-16:00',
      'distance': '0.5 km',
      'icon': '🏥',
      'available': true,
    },
    {
      'name': 'RS Jiwa Jakarta',
      'type': 'Psikiater',
      'address': 'Jl. Kesehatan No. 10, Jakarta',
      'phone': '(021) 8765-4321',
      'hours': '24 Jam',
      'distance': '2.3 km',
      'icon': '🏥',
      'available': true,
    },
    {
      'name': 'Pusat Konseling Mahasiswa',
      'type': 'Konseling',
      'address': 'Gedung Kemahasiswaan Lt.2',
      'phone': '(021) 5555-1234',
      'hours': 'Senin-Sabtu 09:00-17:00',
      'distance': '0.8 km',
      'icon': '💬',
      'available': true,
    },
    {
      'name': 'Hotline Kesehatan Mental 24/7',
      'type': 'Hotline',
      'address': 'Layanan Telepon',
      'phone': '119 ext. 8',
      'hours': '24 Jam',
      'distance': '-',
      'icon': '📞',
      'available': true,
    },
  ];
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  List<Map<String, dynamic>> get filteredLocations {
    return locations.where((location) {
      final matchesService = selectedService.value == 'Semua' || 
                             location['type'] == selectedService.value;
      final matchesSearch = searchQuery.value.isEmpty ||
                            location['name'].toString().toLowerCase()
                                .contains(searchQuery.value.toLowerCase());
      return matchesService && matchesSearch;
    }).toList();
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void selectService(String service) {
    selectedService.value = service;
  }
  
  void callLocation(Map<String, dynamic> location) {
    Get.snackbar(
      'Menelepon',
      location['name'],
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void openRoute(Map<String, dynamic> location) {
    Get.snackbar(
      'Membuka Rute',
      'Rute ke ${location['name']}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
