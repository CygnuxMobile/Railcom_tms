import 'package:get/get.dart';
import 'package:tms_newui/moduls/drs_generate_page/drs_generate_controller.dart';

class DrsGenerateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DrsGenerateController());
  }
}
