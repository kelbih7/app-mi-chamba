import 'package:mi_semana/features/work/data/models/trabajo_dia_detalle_model.dart';

class TrabajoDiaModel {
  final int? id;
  final DateTime fecha;
  final bool estaPagado;
  final List<TrabajoDiaDetalleModel> detalles;

  TrabajoDiaModel({
    this.id,
    required this.fecha,
    required this.estaPagado,
    this.detalles = const [],
  });

  factory TrabajoDiaModel.fromMap(
    Map<String, dynamic> map, {
    List<TrabajoDiaDetalleModel> detalles = const [],
  }) {
    return TrabajoDiaModel(
      id: map['id'] as int?,
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha']),
      estaPagado: (map['esta_pagado'] as int) == 1,
      detalles: detalles,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'fecha': fecha.millisecondsSinceEpoch,
    'esta_pagado': estaPagado ? 1 : 0,
  };
}
