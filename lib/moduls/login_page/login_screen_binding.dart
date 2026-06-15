import 'package:get/get.dart';
import 'package:tms_newui/moduls/login_page/login_controller.dart';

class LoginScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
