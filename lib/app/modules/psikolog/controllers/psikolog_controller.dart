import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../data/in_memory_service.dart';
import '../../../data/models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/session_service.dart';

class PsikologController extends GetxController {
  final String username;

  PsikologController({required this.username});

  final students = <User>[].obs;
  final selectedStudent = Rx<User?>(null);
  final studentEntries = <JournalEntry>[].obs;

  final selectedTab = 0.obs;

  final clientSummaries = <ClientSummary>[].obs;
  final schedules = <ConsultationSchedule>[].obs;
  final messages = <ClientMessage>[].obs;

  final selectedProgram = 'Semua Prodi'.obs;
  final selectedRisk = 'Semua Status'.obs;
  final messageQuery = ''.obs;

  List<String> get programOptions => const [
        'Semua Prodi',
        'Teknik Informatika',
        'Psikologi',
        'Manajemen',
        'Sistem Informasi',
      ];

  List<String> get riskOptions => const [
        'Semua Status',
        'Rendah',
        'Sedang',
        'Tinggi',
      ];

  @override
  void onInit() {
    super.onInit();
    loadStudents();
    _seedDemoContent();
  }

  void changeTab(int index) => selectedTab.value = index;

  void updateProgram(String value) => selectedProgram.value = value;

  void updateRisk(String value) => selectedRisk.value = value;

  void updateMessageQuery(String value) => messageQuery.value = value.trim();

  void loadStudents() {
    students.value = InMemoryService.allUsers()
        .where((u) => !UserRole.isPsychologist(u.role))
        .toList();
  }

  int getStudentEntryCount(String username) {
    return InMemoryService.entriesFor(username).length;
  }

  User? userByUsername(String username) {
    try {
      return students.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  List<ClientSummary> get filteredClientSummaries {
    return clientSummaries.where((summary) {
      final programOk = selectedProgram.value == 'Semua Prodi' ||
          summary.program == selectedProgram.value;
      final riskOk = selectedRisk.value == 'Semua Status' ||
          summary.riskLevel.label == selectedRisk.value;
      return programOk && riskOk;
    }).toList();
  }

  List<ClientMessage> get filteredMessages {
    if (messageQuery.value.isEmpty) return messages;
    final query = messageQuery.value.toLowerCase();
    return messages
        .where(
          (message) =>
              message.name.toLowerCase().contains(query) ||
              message.snippet.toLowerCase().contains(query),
        )
        .toList();
  }

  int get activeClientCount => clientSummaries.length;

  double get averageMood {
    if (clientSummaries.isEmpty) return 0;
    final total = clientSummaries.fold<double>(
      0,
      (sum, client) => sum + client.moodScore,
    );
    return total / clientSummaries.length;
  }

  int get highRiskCount =>
      clientSummaries.where((client) => client.riskLevel == RiskLevel.high).length;

  int get sessionsToday => schedules.length;

  int get sessionsCompleted =>
      schedules.where((schedule) => schedule.isCompleted).length;

  int get unreadMessages =>
      messages.where((message) => message.isUnread).length;

  void viewStudentProfile(User student) {
    selectedStudent.value = student;
    studentEntries.value = InMemoryService.entriesFor(student.username);
  }

  Future<void> logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    try {
      await supa.Supabase.instance.client.auth.signOut();
    } catch (_) {}

    await SessionService.clear();

    if (!context.mounted) return;

    if (Get.isRegistered<PsikologController>()) {
      Get.delete<PsikologController>(force: true);
    }

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _seedDemoContent() {
    clientSummaries.assignAll(const [
      ClientSummary(
        username: 'budi',
        name: 'Budi Santoso',
        program: 'Teknik Informatika',
        location: 'Jakarta Selatan',
        lastActive: '5 menit lalu',
        moodScore: 4.2,
        riskLevel: RiskLevel.low,
      ),
      ClientSummary(
        username: 'siti',
        name: 'Siti Aminah',
        program: 'Psikologi',
        location: 'Tangerang',
        lastActive: '1 jam lalu',
        moodScore: 3.8,
        riskLevel: RiskLevel.medium,
      ),
      ClientSummary(
        username: 'ahmad',
        name: 'Ahmad Rizki',
        program: 'Manajemen',
        location: 'Jakarta Barat',
        lastActive: '3 jam lalu',
        moodScore: 2.5,
        riskLevel: RiskLevel.high,
      ),
    ]);

    schedules.assignAll(const [
      ConsultationSchedule(
        username: 'budi',
        name: 'Budi Santoso',
        sessionId: '2021110001',
        time: '09:00',
        topic: 'Konsultasi Stress Akademik',
        durationMinutes: 60,
        mode: SessionMode.online,
        isCompleted: false,
        moodScore: 3.5,
        riskLevel: RiskLevel.medium,
      ),
      ConsultationSchedule(
        username: 'siti',
        name: 'Siti Aminah',
        sessionId: '2021110002',
        time: '10:30',
        topic: 'Follow-up Anxiety',
        durationMinutes: 45,
        mode: SessionMode.offline,
        isCompleted: true,
        moodScore: 3.8,
        riskLevel: RiskLevel.medium,
      ),
      ConsultationSchedule(
        username: 'ahmad',
        name: 'Ahmad Rizki',
        sessionId: '2021110003',
        time: '13:00',
        topic: 'Depresi & Motivasi',
        durationMinutes: 60,
        mode: SessionMode.online,
        isCompleted: false,
        moodScore: 2.5,
        riskLevel: RiskLevel.high,
      ),
    ]);

    messages.assignAll(const [
      ClientMessage(
        username: 'ahmad',
        name: 'Ahmad Rizki',
        snippet: 'Terima kasih dok atas sesi kemarin...',
        timeAgo: '10 menit lalu',
        moodScore: 2.5,
        riskLevel: RiskLevel.high,
        isUnread: true,
      ),
      ClientMessage(
        username: 'siti',
        name: 'Siti Aminah',
        snippet: 'Baik dok, saya akan coba latihan pernapasan...',
        timeAgo: '1 jam lalu',
        moodScore: 3.8,
        riskLevel: RiskLevel.medium,
        isUnread: true,
      ),
      ClientMessage(
        username: 'budi',
        name: 'Budi Santoso',
        snippet: 'Dok, besok saya bisa konsultasi jam 9?',
        timeAgo: '3 jam lalu',
        moodScore: 4.2,
        riskLevel: RiskLevel.low,
        isUnread: false,
      ),
      ClientMessage(
        username: 'dewile',
        name: 'Dewi Lestari',
        snippet: 'Terima kasih banyak dok atas arahannya.',
        timeAgo: '5 jam lalu',
        moodScore: 4.5,
        riskLevel: RiskLevel.low,
        isUnread: false,
      ),
    ]);
  }
}

enum RiskLevel { low, medium, high }

extension RiskLevelLabel on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Rendah';
      case RiskLevel.medium:
        return 'Sedang';
      case RiskLevel.high:
        return 'Tinggi';
    }
  }
}

enum SessionMode { online, offline }

extension SessionModeLabel on SessionMode {
  String get label => this == SessionMode.online ? 'Online' : 'Offline';
}

class ClientSummary {
  final String username;
  final String name;
  final String program;
  final String location;
  final String lastActive;
  final double moodScore;
  final RiskLevel riskLevel;

  const ClientSummary({
    required this.username,
    required this.name,
    required this.program,
    required this.location,
    required this.lastActive,
    required this.moodScore,
    required this.riskLevel,
  });
}

class ConsultationSchedule {
  final String username;
  final String name;
  final String sessionId;
  final String time;
  final String topic;
  final int durationMinutes;
  final SessionMode mode;
  final bool isCompleted;
  final double moodScore;
  final RiskLevel riskLevel;

  const ConsultationSchedule({
    required this.username,
    required this.name,
    required this.sessionId,
    required this.time,
    required this.topic,
    required this.durationMinutes,
    required this.mode,
    required this.isCompleted,
    required this.moodScore,
    required this.riskLevel,
  });
}

class ClientMessage {
  final String username;
  final String name;
  final String snippet;
  final String timeAgo;
  final double moodScore;
  final RiskLevel riskLevel;
  final bool isUnread;

  const ClientMessage({
    required this.username,
    required this.name,
    required this.snippet,
    required this.timeAgo,
    required this.moodScore,
    required this.riskLevel,
    required this.isUnread,
  });
}
