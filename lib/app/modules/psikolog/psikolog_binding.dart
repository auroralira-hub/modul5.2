import 'package:get/get.dart';
import 'controllers/psikolog_controller.dart';

class PsikologBinding extends Bindings {
  final String username;
  
  PsikologBinding({required this.username});
  
  @override
  void dependencies() {
    Get.lazyPut<PsikologController>(
      () => PsikologController(username: username),
    );
  }
}
