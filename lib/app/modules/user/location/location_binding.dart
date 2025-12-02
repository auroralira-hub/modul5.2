import 'package:get/get.dart';
import 'controllers/location_controller.dart';
import 'package:demo_3/app/data/models.dart';

class LocationBinding extends Bindings {
  final User user;
  
  LocationBinding({required this.user});
  
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(
      () => LocationController(user: user),
    );
  }
}
