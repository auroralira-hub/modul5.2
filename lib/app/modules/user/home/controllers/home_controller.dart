import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_3/app/data/models.dart';
import 'package:demo_3/app/modules/user/providers/user_provider.dart';

class HomeController extends GetxController {
  // Controllers
  final journalCtrl = TextEditingController();
  
  // Observables
  final selectedMoodIndex = (-1).obs;
  final stressValue = 5.obs;
  final selectedDate = DateTime.now().obs;
  
  // User provider
  late final UserProvider provider;
  final User user;
  
  HomeController({required this.user});
  
  final List<Map<String, dynamic>> moods = [
    {'name': 'Lelah', 'emoji': '😩', 'color': const Color(0xFFFFB74D)},
    {'name': 'Marah', 'emoji': '😠', 'color': const Color(0xFFFF7043)},
    {'name': 'Senang', 'emoji': '😊', 'color': const Color(0xFF66BB6A)},
    {'name': 'Sedih', 'emoji': '😢', 'color': const Color(0xFF42A5F5)},
    {'name': 'Cemas', 'emoji': '😰', 'color': const Color(0xFF9575CD)},
    {'name': 'Bersyukur', 'emoji': '🙏', 'color': const Color(0xFFFFA726)},
  ];
  
  @override
  void onInit() {
    super.onInit();
    provider = UserProvider(user: user);
  }
  
  @override
  void onClose() {
    journalCtrl.dispose();
    provider.dispose();
    super.onClose();
  }
  
  Future<void> saveEntry() async {
    if (provider.isSaving) return;
    
    final mood = selectedMoodIndex.value >= 0
        ? moods[selectedMoodIndex.value]['name'] as String
        : 'Unspecified';
        
    final entry = JournalEntry(
      username: user.username,
      mood: mood,
      stressLevel: stressValue.value,
      note: journalCtrl.text.trim(),
      timestamp: DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
    );
    
    try {
      await provider.addEntry(entry);
      journalCtrl.clear();
      selectedMoodIndex.value = -1;
      stressValue.value = 5;
      Get.snackbar(
        'Berhasil',
        'Jurnal berhasil disimpan!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  int calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;
    
    final sortedEntries = entries.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int streak = 1;
    DateTime lastDate = sortedEntries.first.timestamp;
    
    for (int i = 1; i < sortedEntries.length; i++) {
      final currentDate = sortedEntries[i].timestamp;
      final daysDiff = lastDate.difference(currentDate).inDays;
      
      if (daysDiff == 1) {
        streak++;
        lastDate = currentDate;
      } else if (daysDiff > 1) {
        break;
      }
    }
    
    return streak;
  }
  
  void selectMood(int index) {
    selectedMoodIndex.value = index;
  }
  
  void updateStressLevel(double value) {
    stressValue.value = value.toInt();
  }
}
