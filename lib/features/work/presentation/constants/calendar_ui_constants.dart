import 'package:flutter/material.dart';

class CalendarUiConstants {
  // Estados
  static final Color paidColor = Colors.green;
  static final Color pendingColor = Colors.orange;

  // Selección
  static final Color selectedDayColor = Colors.blueGrey;
  static final Color todayColor = Colors.lightBlue;

  // Colores por semana
  static final List<Color> weekColors = [
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.amber,
    Colors.red,
    Colors.lightGreen,
    Colors.pink,
  ];
  // =========================
  // HELPERS DE UI
  // =========================

  /// Color según el estado ACTUAL
  static Color colorPorEstado(bool estaPagada) {
    return estaPagada ? paidColor : pendingColor;
  }
}
