// lib/constants/months_constants.dart

class MonthsConstants {
  // Nueva lista de nombres de días completos en español (Lunes = 1)
  static const List<String> dayFullNames = [
    '', // Índice 0 vacío (Dart DateTime.weekday va de 1 (Lunes) a 7 (Domingo))
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  // Lista de abreviaturas de meses en español
  static const List<String> monthAbbreviations = [
    '', // Índice 0 vacío para que enero sea 1
    'Ene', // Enero
    'Feb', // Febrero
    'Mar', // Marzo
    'Abr', // Abril
    'May', // Mayo
    'Jun', // Junio
    'Jul', // Julio
    'Ago', // Agosto
    'Sep', // Septiembre
    'Oct', // Octubre
    'Nov', // Noviembre
    'Dic', // Diciembre
  ];

  // Lista de nombres completos de meses en español
  static const List<String> monthFullNames = [
    '', // Índice 0 vacío
    'Enero', // Enero
    'Febrero', // Febrero
    'Marzo', // Marzo
    'Abril', // Abril
    'Mayo', // Mayo
    'Junio', // Junio
    'Julio', // Julio
    'Agosto', // Agosto
    'Septiembre', // Septiembre
    'Octubre', // Octubre
    'Noviembre', // Noviembre
    'Diciembre', // Diciembre
  ];

  static const List<String> dayAbbreviations = [
    '', // índice 0 vacío
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  static String getDayAbbreviation(int day) {
    if (day >= 1 && day <= 7) {
      return dayAbbreviations[day];
    }
    return '';
  }

  // Método para obtener el nombre completo del día
  static String getDayFullName(int day) {
    if (day >= 1 && day <= 7) {
      return dayFullNames[day];
    }
    return '';
  }

  // Método para obtener la abreviatura del mes
  static String getMonthAbbreviation(int month) {
    if (month >= 1 && month <= 12) {
      return monthAbbreviations[month];
    }
    return '';
  }

  // Método para obtener el nombre completo del mes
  static String getMonthFullName(int month) {
    if (month >= 1 && month <= 12) {
      return monthFullNames[month];
    }
    return '';
  }

  // Método para formatear una fecha simple (ej: "3 Oct 2025")
  static String formatDate(DateTime date) {
    return '${date.day} ${getMonthAbbreviation(date.month)} ${date.year}';
  }

  // Nuevo método para formatear la fecha completa (ej: "Lunes 1 de Septiembre")
  static String formatFullDateWithDay(DateTime date) {
    // DateTime.weekday devuelve 1 (Lunes) a 7 (Domingo)
    final dayOfWeek = getDayFullName(date.weekday);
    final dayOfMonth = date.day;
    final monthName = getMonthFullName(date.month);

    return '$dayOfWeek $dayOfMonth de $monthName';
  }
}
