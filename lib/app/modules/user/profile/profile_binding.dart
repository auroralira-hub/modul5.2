import 'package:get/get.dart';
import 'controllers/profile_controller.dart';
import 'package:demo_3/app/data/models.dart';

class ProfileBinding extends Bindings {
  final User user;
  
  ProfileBinding({required this.user});
  
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(user: user),
    );
  }
}
