class EstadoDiaCalendarioModel {
  final DateTime fecha;
  final bool tieneRegistro;
  final bool estaPagado;

  EstadoDiaCalendarioModel({
    required this.fecha,
    required this.tieneRegistro,
    required this.estaPagado,
  });

  factory EstadoDiaCalendarioModel.fromMap(Map<String, dynamic> map) {
    return EstadoDiaCalendarioModel(
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha']),
      tieneRegistro: map['tiene_registro'] == 1,
      estaPagado: map['esta_pagado'] == 1,
    );
  }
}
