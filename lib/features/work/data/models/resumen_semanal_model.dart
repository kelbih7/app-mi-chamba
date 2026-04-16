import 'package:mi_semana/features/work/domain/entities/resumen_semana.dart';

class ResumenSemanaModel extends ResumenSemana {
  ResumenSemanaModel({
    required super.weekNumber,
    required super.startDate,
    required super.endDate,
    required super.estaPagada,
    required super.resumenActividades,
    required super.total,
    required super.dias,
  });
}
