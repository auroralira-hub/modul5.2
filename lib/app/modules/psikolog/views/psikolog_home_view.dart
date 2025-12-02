import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../routes/app_routes.dart';
import '../../../services/session_service.dart';
import '../controllers/psikolog_controller.dart';
import 'psikolog_student_detail_view.dart';

class PsikologHomeView extends GetView<PsikologController> {
  const PsikologHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Psikolog - ${controller.username}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() => _buildStudentList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Obx(() => Card(
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
        subtitle: Text('Jumlah terdaftar: ${controller.students.length}'),
      ),
    ));
  }

  Widget _buildStudentList() {
    if (controller.students.isEmpty) {
      return Center(
        child: Text(
          'Belum ada mahasiswa terdaftar',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.separated(
      itemCount: controller.students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final student = controller.students[index];
        final entryCount = controller.getStudentEntryCount(student.username);
        
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                student.name.isNotEmpty
                    ? student.name[0].toUpperCase()
                    : 'U',
              ),
            ),
            title: Text(student.name),
            subtitle: Text(
              '${student.major} • ${student.age} tahun • entri: $entryCount',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                controller.viewStudentProfile(student);
                Get.to(
                  () => const PsikologStudentDetailView(),
                  transition: Transition.fade,
                  duration: const Duration(milliseconds: 380),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Future<void> _confirmLogout(BuildContext context) async {
  final bool? ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Konfirmasi Logout'),
      content: const Text('Apakah Anda yakin ingin keluar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (ok != true) return;
  try { await supa.Supabase.instance.client.auth.signOut(); } catch (_) {}
  await SessionService.clear();
  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.login,
    (route) => false,
  );
}
