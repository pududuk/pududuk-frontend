import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pududuk_app/app/modules/affiliation/bindings/affiliation_binding.dart';
import 'package:pududuk_app/app/modules/affiliation/views/affiliation_view.dart';
import 'package:pududuk_app/app/modules/recommend_result/bindings/recommend_result_binding.dart';
import 'package:pududuk_app/app/modules/recommend_result/views/map_result_conditional.dart';
import 'package:pududuk_app/app/modules/recommend_result/views/recommend_result_view.dart';
import 'package:pududuk_app/app/modules/survey/bindings/survey_binding.dart';
import 'package:pududuk_app/app/modules/survey/views/survey_view.dart';
import 'package:pududuk_app/app/modules/login/bindings/login_binding.dart';
import 'package:pududuk_app/app/modules/login/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const AffiliationView(),
      binding: AffiliationBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.SURVEY,
      page: () => const SurveyView(),
      binding: SurveyBinding(),
    ),
    GetPage(
      name: Routes.RECOMMEND_RESULT,
      page: () => const RecommendResultView(),
      binding: RecommendResultBinding(),
    ),
    GetPage(
      name: Routes.MAP_RESULT,
      page: () => getConditionalMapView(),
      binding: RecommendResultBinding(),
    ),
  ];
}
