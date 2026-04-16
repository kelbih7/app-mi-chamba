import 'package:flutter/material.dart';
import 'package:mi_semana/features/work/presentation/screens/calendar_screen.dart';

import 'navigator_key.dart';

class NotificationRouter {
  static void openTodayFromNotification() {
    final today = DateTime.now();
    final dayOnly = DateTime(today.year, today.month, today.day);

    // Asegurar que el navegador esté disponible
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => CalendarScreen(openDay: dayOnly)),
        (route) => false,
      );
    }
  }
}
