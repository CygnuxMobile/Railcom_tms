import 'package:get/get.dart';
import 'package:tms_newui/moduls/qr_page/qr_scan_ontroller.dart';

class QrScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrScanController>(() => QrScanController());
  }
}
