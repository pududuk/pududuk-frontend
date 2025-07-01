import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyController extends GetxController {
  var age = '25'.obs;
  var gender = ''.obs;
  var waitTime = 'yes'.obs;
  var nearby = 'yes'.obs;
  var preferredFoods = ''.obs;
  var restrictions = ''.obs;

  final ageController = TextEditingController(text: '25');

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

    final savedAge = prefs.getString('survey_age') ?? '25';
    final savedGender = prefs.getString('survey_gender') ?? '';
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
    restrictions.value = savedRestrictions;
  }

  @override
  void onClose() {
    ageController.dispose();
    super.onClose();
  }
}
