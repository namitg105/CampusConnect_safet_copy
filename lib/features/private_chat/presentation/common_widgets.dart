import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSuccessSnackbar(String message, {String title = 'Success'}) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF6139ED),
    colorText: Colors.white,
    borderRadius: 12,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    isDismissible: true,
    duration: const Duration(seconds: 2),
    icon: const Icon(Icons.check_circle, color: Colors.white, size: 22),
    titleText: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
    ),
  );
}

void showErrorSnackbar(String message, {String title = 'Error'}) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFFE53935),
    colorText: Colors.white,
    borderRadius: 12,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    isDismissible: true,
    duration: const Duration(seconds: 2),
    icon: const Icon(Icons.error_outline, color: Colors.white, size: 22),
    titleText: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
    ),
  );
}

void showInfoSnackbar(String message, {String title = 'Info'}) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF1A73E8),
    colorText: Colors.white,
    borderRadius: 12,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    isDismissible: true,
    duration: const Duration(seconds: 2),
    icon: const Icon(Icons.info_outline, color: Colors.white, size: 22),
    titleText: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
    ),
  );
}
