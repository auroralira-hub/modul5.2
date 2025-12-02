import 'package:get/get.dart';
import 'controllers/home_controller.dart';
import 'package:demo_3/app/data/models.dart';

class HomeBinding extends Bindings {
  final User user;
  
  HomeBinding({required this.user});
  
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(user: user),
    );
  }
}
