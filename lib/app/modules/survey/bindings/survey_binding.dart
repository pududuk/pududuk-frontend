import 'package:get/get.dart';
import 'package:pududuk_app/app/modules/survey/controllers/survey_controller.dart';

class SurveyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurveyController>(() => SurveyController());
  }
}
