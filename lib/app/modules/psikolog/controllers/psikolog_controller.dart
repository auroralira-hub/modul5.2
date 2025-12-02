import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../data/models.dart';
import '../../../data/in_memory_service.dart';
import '../../../routes/app_routes.dart';
import '../../../services/session_service.dart';

class PsikologController extends GetxController {
  final String username;
  
  PsikologController({required this.username});
  
  // Observables
  final students = <User>[].obs;
  final selectedStudent = Rx<User?>(null);
  final studentEntries = <JournalEntry>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }
  
  void loadStudents() {
    students.value = InMemoryService.allUsers()
        .where((u) => !UserRole.isPsychologist(u.role))
        .toList();
  }
  
  int getStudentEntryCount(String username) {
    return InMemoryService.entriesFor(username).length;
  }
  
  void viewStudentProfile(User student) {
    selectedStudent.value = student;
    studentEntries.value = InMemoryService.entriesFor(student.username);
  }
  
  void logout() {
    Get.defaultDialog(
      title: 'Konfirmasi Logout',
      middleText: 'Apakah Anda yakin ingin keluar?',
      textConfirm: 'Ya',
      textCancel: 'Tidak',
      onConfirm: () async {
        Get.back();
        try { await supa.Supabase.instance.client.auth.signOut(); } catch (_) {}
        await SessionService.clear();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }
}
