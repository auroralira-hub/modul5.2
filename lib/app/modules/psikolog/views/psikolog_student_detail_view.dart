import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/psikolog_controller.dart';

class PsikologStudentDetailView extends GetView<PsikologController> {
  const PsikologStudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        final student = controller.selectedStudent.value;
        if (student == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStudentHeader(student),
              const SizedBox(height: 12),
              _buildStudentInfo(student),
              const SizedBox(height: 12),
              const Text(
                'Riwayat Entri:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildEntryList()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStudentHeader(student) {
    return Column(
      children: [
        CircleAvatar(
          radius: 46,
          child: Text(
            student.name.isNotEmpty ? student.name[0] : 'U',
            style: const TextStyle(fontSize: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          student.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStudentInfo(student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _infoRow('Username', student.username),
            _infoRow('Nama', student.name),
            _infoRow('Usia', '${student.age}'),
            _infoRow('Jurusan', student.major),
            _infoRow('Email', student.email),
            _infoRow('Jumlah Entri', '${controller.studentEntries.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryList() {
    return Obx(() {
      if (controller.studentEntries.isEmpty) {
        return Center(
          child: Text(
            'Belum ada entri',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.studentEntries.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final entry = controller.studentEntries[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(entry.mood.isNotEmpty ? entry.mood[0] : 'M'),
            ),
            title: Text('${entry.mood} • Stress ${entry.stressLevel}/10'),
            subtitle: Text(
              entry.note.isEmpty ? '(tidak ada catatan)' : entry.note,
            ),
            trailing: Text(
              '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
            ),
          );
        },
      );
    });
  }

  Widget _infoRow(String label, String value) {
    return Padding(
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
  }
}
