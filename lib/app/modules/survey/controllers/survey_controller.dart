import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
    ever(age, (String value) {
      if (ageController.text != value) {
        ageController.text = value;
        ageController.selection = TextSelection.collapsed(offset: value.length);
      }
    });
  }

  @override
  void onClose() {
    ageController.dispose();
    super.onClose();
  }
}
