import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_3/app/data/models.dart';

class EducationController extends GetxController {
  // Controllers
  final searchController = TextEditingController();
  
  // Observables
  final searchQuery = ''.obs;
  final selectedCategory = 'Semua'.obs;
  
  final User user;
  
  EducationController({required this.user});
  
  // Categories
  final List<String> categories = [
    'Semua',
    'Kecemasan',
    'Depresi',
    'Stress',
    'Motivasi',
    'Tips Sehat'
  ];
  
  // Articles data
  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Mengelola Stress Akademik',
      'category': 'Stress',
      'excerpt': 'Tips praktis untuk mahasiswa menghadapi tekanan kuliah...',
      'image': '📚',
      'readTime': '5 min',
    },
    {
      'title': 'Mengatasi Kecemasan Sosial',
      'category': 'Kecemasan',
      'excerpt': 'Cara efektif mengurangi kecemasan saat berinteraksi...',
      'image': '🤝',
      'readTime': '7 min',
    },
    {
      'title': 'Pentingnya Self-Care',
      'category': 'Tips Sehat',
      'excerpt': 'Rutinitas harian yang dapat meningkatkan kesehatan mental...',
      'image': '💆',
      'readTime': '6 min',
    },
    {
      'title': 'Motivasi di Masa Sulit',
      'category': 'Motivasi',
      'excerpt': 'Bangkit dari keterpurukan dan menemukan semangat baru...',
      'image': '💪',
      'readTime': '4 min',
    },
  ];
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  List<Map<String, dynamic>> get filteredArticles {
    return articles.where((article) {
      final matchesCategory = selectedCategory.value == 'Semua' || 
                              article['category'] == selectedCategory.value;
      final matchesSearch = searchQuery.value.isEmpty ||
                            article['title'].toString().toLowerCase()
                                .contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void selectCategory(String category) {
    selectedCategory.value = category;
  }
  
  void openArticle(Map<String, dynamic> article) {
    Get.snackbar(
      'Membuka Artikel',
      article['title'],
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
