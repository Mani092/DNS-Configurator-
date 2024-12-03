

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ThemeController extends GetxController {
  var themeMode = ThemeMode.light.obs; // Default theme is light

  // Toggle between light and dark mode
  void toggleTheme() {
    themeMode.value =
    themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    // Apply the theme globally
    Get.changeThemeMode(themeMode.value);
  }
}