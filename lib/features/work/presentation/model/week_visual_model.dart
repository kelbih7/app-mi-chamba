import 'package:flutter/material.dart';

class WeekVisualModel {
  final int weekNumber;
  final DateTime start;
  final DateTime end;
  final Color color;

  const WeekVisualModel({
    required this.weekNumber,
    required this.start,
    required this.end,
    required this.color,
  });
}
