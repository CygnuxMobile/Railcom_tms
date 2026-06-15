import 'package:get/get.dart';
import 'package:tms_newui/moduls/trecking_page/tracking_controller.dart';

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<TrackingController>(() => TrackingController());
  }
}
