import 'package:flutter/material.dart';

import '../../data/in_memory_service.dart';
import '../../data/models.dart';
import '../../routes/app_routes.dart';
import '../../services/session_service.dart';
import '../../widgets/theme_toggle_action.dart';

/* ===========================
   Dosen Home
   =========================== */

class DosenHomePage extends StatelessWidget {
  final String username;
  const DosenHomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final users = InMemoryService.allUsers();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Dosen - $username'),
        backgroundColor: Colors.deepPurple,
        actions: [
          const ThemeToggleAction(),
          IconButton(
            onPressed: () async {
              await SessionService.clear();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                color: Colors.deepPurple.shade50,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(
                      Icons.monitor_heart,
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: const Text('Monitoring Mahasiswa'),
                  subtitle: Text('Jumlah terdaftar: ${users.length}'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada mahasiswa terdaftar',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (c, i) {
                          final u = users[i];
                          final count = InMemoryService.entriesFor(
                            u.username,
                          ).length;
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  u.name.isNotEmpty
                                      ? u.name[0].toUpperCase()
                                      : 'U',
                                ),
                              ),
                              title: Text(u.name),
                              subtitle: Text(
                                '${u.major} • ${u.age} tahun • entri: $count',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, anim, __) =>
                                        FadeTransition(
                                          opacity: anim,
                                          child:
                                              DosenViewUserProfileWithHistory(
                                                user: u,
                                              ),
                                        ),
                                    transitionDuration: const Duration(
                                      milliseconds: 380,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DosenViewUserProfileWithHistory extends StatelessWidget {
  final User user;
  const DosenViewUserProfileWithHistory({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final entries = InMemoryService.entriesFor(user.username);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Colors.deepPurple,
        actions: const [ThemeToggleAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 46,
              child: Text(
                user.name.isNotEmpty ? user.name[0] : 'U',
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _infoRow('Username', user.username),
                    _infoRow('Nama', user.name),
                    _infoRow('Usia', '${user.age}'),
                    _infoRow('Jurusan', user.major),
                    _infoRow('Email', user.email),
                    _infoRow('Jumlah Entri', '${entries.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Riwayat Entri:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada entri',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (c, i) {
                        final e = entries[i];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(e.mood.isNotEmpty ? e.mood[0] : 'M'),
                          ),
                          title: Text('${e.mood} • Stress ${e.stressLevel}/10'),
                          subtitle: Text(
                            e.note.isEmpty ? '(tidak ada catatan)' : e.note,
                          ),
                          trailing: Text(
                            '${e.timestamp.day}/${e.timestamp.month}/${e.timestamp.year}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _infoRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    children: [
      SizedBox(
        width: 110,
        child: Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      Expanded(child: Text(value)),
    ],
  ),
);
