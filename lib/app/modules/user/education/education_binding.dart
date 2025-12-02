import 'package:get/get.dart';
import 'controllers/education_controller.dart';
import 'package:demo_3/app/data/models.dart';

class EducationBinding extends Bindings {
  final User user;
  
  EducationBinding({required this.user});
  
  @override
  void dependencies() {
    Get.lazyPut<EducationController>(
      () => EducationController(user: user),
    );
  }
}
