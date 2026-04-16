import 'dart:ui';
import 'package:mi_semana/core/utils/date_day_mapper.dart';
import 'package:mi_semana/core/utils/week_domain_helper.dart';
import 'package:mi_semana/features/work/presentation/constants/calendar_ui_constants.dart';
import 'package:mi_semana/features/work/presentation/model/week_visual_model.dart';

/// Mapeador para construir semanas visuales del calendario
class CalendarWeekMapper {
  const CalendarWeekMapper._();

  /// Construye las semanas visuales para un mes dado
  static List<WeekVisualModel> buildWeeks(DateTime focusedMonth) {
    final weeks = <WeekVisualModel>[];

    // Usamos el helper de dominio para obtener el rango
    final (firstMonday, lastSunday) = WeekDomainHelper.getVisibleWeekRange(
      focusedMonth,
    );

    // Obtenemos todas las semanas del rango
    final weekStarts = WeekDomainHelper.getWeekStartsInRange(
      firstMonday,
      lastSunday,
    );

    int colorIndex = 0;

    for (final monday in weekStarts) {
      weeks.add(
        WeekVisualModel(
          weekNumber: WeekDomainHelper.weekNumber(monday),
          start: DateDayMapper.toLocalDay(monday), // lunes
          end: DateDayMapper.toLocalDay(
            monday.add(const Duration(days: 6)),
          ), // domingo
          color: CalendarUiConstants
              .weekColors[colorIndex % CalendarUiConstants.weekColors.length],
        ),
      );
      colorIndex++;
    }

    return weeks;
  }

  /// Obtiene el color para un día específico
  static Color? colorForDay(DateTime day, List<WeekVisualModel> weeks) {
    final d = DateDayMapper.toLocalDay(day);

    for (final week in weeks) {
      if (!d.isBefore(week.start) && !d.isAfter(week.end)) {
        return week.color;
      }
    }
    return null;
  }
}
