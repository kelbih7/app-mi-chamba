/// Helper exclusivo para fechas que representan un DÍA (DATE ONLY)
/// Uso: normalmente en datasources
class DateDayMapper {
  const DateDayMapper._();

  /// Normaliza a día LOCAL (00:00)
  static DateTime toLocalDay(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  /// Convierte día local normalizado a millis
  static int toLocalDayMillis(DateTime d) {
    return toLocalDay(d).millisecondsSinceEpoch;
  }

  /// Convierte millis de DB a día local normalizado
  static DateTime fromMillis(int millis) {
    return toLocalDay(DateTime.fromMillisecondsSinceEpoch(millis));
  }
}
