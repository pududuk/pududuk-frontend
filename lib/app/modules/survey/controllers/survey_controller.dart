import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyController extends GetxController {
  var age = '25'.obs;
  var gender = 'male'.obs;
  var waitTime = 'yes'.obs;
  var nearby = 'yes'.obs;
  var preferredFoods = ''.obs;
  var restrictions = ''.obs;
  var hasExistingData = false.obs;

  final ageController = TextEditingController(text: '25');
  final preferredFoodsController = TextEditingController();
  final restrictionsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    ever(age, (String value) {
      if (ageController.text != value) {
        ageController.text = value;
        ageController.selection = TextSelection.collapsed(offset: value.length);
      }
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 실제 저장된 데이터가 있는지 확인
    final hasStoredData =
        prefs.containsKey('survey_age') ||
        prefs.containsKey('survey_gender') ||
        prefs.containsKey('survey_waitTime') ||
        prefs.containsKey('survey_nearby') ||
        prefs.containsKey('survey_preferredFoods') ||
        prefs.containsKey('survey_restrictions');

    final savedAge = prefs.getString('survey_age') ?? '25';
    final savedGender = prefs.getString('survey_gender') ?? 'male';
    final savedWaitTime = prefs.getString('survey_waitTime') ?? 'yes';
    final savedNearby = prefs.getString('survey_nearby') ?? 'yes';
    final savedPreferredFoods = prefs.getString('survey_preferredFoods') ?? '';
    final savedRestrictions = prefs.getString('survey_restrictions') ?? '';

    age.value = savedAge;
    ageController.text = savedAge;
    gender.value = savedGender;
    waitTime.value = savedWaitTime;
    nearby.value = savedNearby;
    preferredFoods.value = savedPreferredFoods;
    preferredFoodsController.text = savedPreferredFoods;
    restrictions.value = savedRestrictions;
    restrictionsController.text = savedRestrictions;

    // 실제 저장된 데이터가 있는지 확인
    hasExistingData.value = hasStoredData;
  }

  @override
  void onClose() {
    ageController.dispose();
    preferredFoodsController.dispose();
    restrictionsController.dispose();
    super.onClose();
  }
}
