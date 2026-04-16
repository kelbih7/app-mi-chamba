import 'package:flutter/material.dart';
import 'app_toast_widget.dart';

class AppToastEntry {
  AppToastEntry._();
  static final AppToastEntry instance = AppToastEntry._();

  OverlayEntry? _entry;

  void show(
    BuildContext context, {
    required String message,
    required bool isSuccess,
    required Duration duration,
  }) {
    // Reemplaza toast activo
    dismiss();

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: AppToastWidget(
          message: message,
          isSuccess: isSuccess,
          duration: duration,
          onDismiss: dismiss,
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}
