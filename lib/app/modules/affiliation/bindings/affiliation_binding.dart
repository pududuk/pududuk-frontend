import 'package:get/get.dart';
import '../controllers/affiliation_controller.dart';

class AffiliationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AffiliationController>(() => AffiliationController());
  }
}
