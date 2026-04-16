import 'package:flutter/material.dart';
import 'app_toast_entry.dart';

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    required bool isSuccess,
    Duration? duration,
  }) {
    AppToastEntry.instance.show(
      context,
      message: message,
      isSuccess: isSuccess,
      duration:
          duration ??
          (isSuccess ? const Duration(seconds: 1) : const Duration(seconds: 3)),
    );
  }

  static void dismiss() {
    AppToastEntry.instance.dismiss();
  }
}
