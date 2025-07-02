import 'package:get/get.dart';
import '../controllers/recommend_result_controller.dart';

class RecommendResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecommendResultController>(() => RecommendResultController());
  }
}
