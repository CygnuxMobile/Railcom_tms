import 'package:get/get.dart';
import 'prs_generate_controller.dart';

class PRSGenerateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PRSGenerateController>(
      () => PRSGenerateController(),
    );
  }
}
