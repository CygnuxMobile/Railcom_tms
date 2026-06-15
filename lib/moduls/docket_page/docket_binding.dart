import 'package:get/get.dart';
import 'package:tms_newui/moduls/docket_page/docket_controller.dart';



class DocketBinding extends Bindings {


  @override
  void dependencies() {
    Get.lazyPut<DocketController>(() => DocketController());
  }
}

