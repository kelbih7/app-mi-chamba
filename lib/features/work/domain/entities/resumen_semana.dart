import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';

class ResumenSemana {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final bool estaPagada; // true = pagada, false = pendiente
  final String resumenActividades; // ej: [4C + 1D + 1A + 4R]
  final double total; // suma de pagos de la semana
  final List<TrabajoDia> dias; // para poder mostrar detalle

  ResumenSemana({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.estaPagada,
    required this.resumenActividades,
    required this.total,
    required this.dias,
  });
}
