import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData displayIcon;

    if (isError) {
      backgroundColor = Colors.redAccent.withValues(alpha:0.9);
      displayIcon = icon ?? Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = Colors.green.withValues(alpha:0.9);
      displayIcon = icon ?? Icons.check_circle_outline;
    } else {
      backgroundColor = Colors.blueAccent.withValues(alpha:0.9);
      displayIcon = icon ?? Icons.info_outline;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Icon(displayIcon, color: Colors.white),
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      duration: duration,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  static void success(String message, {String title = "Success"}) {
    show(title: title, message: message, isSuccess: true);
  }

  static void error(String message, {String title = "Error"}) {
    show(title: title, message: message, isError: true);
  }

  static void info(String message, {String title = "Info"}) {
    show(title: title, message: message);
  }
}
