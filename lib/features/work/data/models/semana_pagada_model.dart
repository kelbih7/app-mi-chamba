import 'package:mi_semana/features/work/domain/entities/semana_pagada.dart';

class SemanaPagadaModel extends SemanaPagada {
  const SemanaPagadaModel({
    required super.inicioSemana,
    required super.finSemana,
    required super.fechaPago,
  });

  factory SemanaPagadaModel.fromMap(Map<String, dynamic> map) {
    return SemanaPagadaModel(
      inicioSemana: DateTime.fromMillisecondsSinceEpoch(
        map['inicio_semana'] as int,
      ),
      finSemana: DateTime.fromMillisecondsSinceEpoch(map['fin_semana'] as int),
      fechaPago: DateTime.fromMillisecondsSinceEpoch(map['fecha_pago'] as int),
    );
  }

  // convertir de Entity a Model
  factory SemanaPagadaModel.fromEntity(SemanaPagada entity) {
    return SemanaPagadaModel(
      inicioSemana: entity.inicioSemana,
      finSemana: entity.finSemana,
      fechaPago: entity.fechaPago,
    );
  }
}
