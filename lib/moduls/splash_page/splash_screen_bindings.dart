import 'package:get/get.dart';
import 'package:tms_newui/moduls/splash_page/splash_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(() => SplashScreenController());
  }
}
