import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LightModeController extends GetxController {
  var isLightMode = true.obs; // Default to light mode
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    isLightMode.value = _storage.read('isLightMode') ?? true;
    Get.changeThemeMode(isLightMode.value ? ThemeMode.light : ThemeMode.dark);
    super.onInit();
  }

  void toggleLightMode() {
    isLightMode.value = !isLightMode.value;
    _storage.write('isLightMode', isLightMode.value);
    Get.changeThemeMode(isLightMode.value ? ThemeMode.light : ThemeMode.dark);
  }
}
