// Export views and controllers for backward compatibility
export 'views/psikolog_home_view.dart';
export 'views/psikolog_student_detail_view.dart';
export 'controllers/psikolog_controller.dart';
export 'psikolog_binding.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/psikolog_controller.dart';
import 'views/psikolog_home_view.dart';

/* ===========================
   Psikolog Pages - Wrapper for backward compatibility
   Menggunakan GetX pattern dengan Controller dan View terpisah
   
   Struktur baru:
   - controllers/psikolog_controller.dart (Business logic)
   - views/psikolog_home_view.dart (Home UI)
   - views/psikolog_student_detail_view.dart (Detail UI)
   - psikolog_binding.dart (Dependency injection)
   =========================== */

// Wrapper class untuk backward compatibility dengan kode lama
class psikologHomePage extends StatelessWidget {
  final String username;
  const psikologHomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller jika belum ada
    Get.lazyPut(() => PsikologController(username: username));
    
    return const PsikologHomeView();
  }
}
