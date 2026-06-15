import 'package:get/get.dart';
import 'package:tms_newui/moduls/stock_update_page/stock_update_controller.dart';

class StockUpdateBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<StockUpdateController>(() => StockUpdateController());
  }
}
