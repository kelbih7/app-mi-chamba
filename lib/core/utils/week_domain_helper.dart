/// Helper de dominio para operaciones con semanas
/// Regla de negocio: La semana empieza el lunes y termina el domingo
class WeekDomainHelper {
  const WeekDomainHelper._();

  /// Obtiene el lunes de la semana de una fecha
  static DateTime startOfWeek(DateTime date) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    return dayOnly.subtract(Duration(days: dayOnly.weekday - 1));
  }

  /// Obtiene el domingo de la semana de una fecha
  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  /// Calcula el número de semana ISO 8601
  static int weekNumber(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    // mover al jueves de la misma semana (regla ISO)
    final adjusted = day.add(Duration(days: 4 - day.weekday));
    final yearStart = DateTime(adjusted.year, 1, 1);

    return ((adjusted.difference(yearStart).inDays) ~/ 7) + 1;
  }

  /// Obtiene el rango de semanas visibles para un mes
  static (DateTime firstMonday, DateTime lastSunday) getVisibleWeekRange(
    DateTime month,
  ) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final firstMonday = startOfWeek(firstDayOfMonth);
    final lastSunday = endOfWeek(lastDayOfMonth);

    return (firstMonday, lastSunday);
  }

  /// Genera todas las fechas de inicio de semana (lunes) en un rango
  static List<DateTime> getWeekStartsInRange(DateTime start, DateTime end) {
    final weeks = <DateTime>[];
    var cursor = startOfWeek(start);

    while (!cursor.isAfter(end)) {
      weeks.add(cursor);
      cursor = cursor.add(const Duration(days: 7));
    }
    if (start.isAfter(end)) return [];
    return weeks;
  }
}
