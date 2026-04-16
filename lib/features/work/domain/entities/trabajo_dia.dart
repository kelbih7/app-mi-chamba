import 'package:mi_semana/features/work/domain/entities/trabajo_dia_detalle.dart';

///Representa "el día que trabajaste" (jornada laboral)
class TrabajoDia {
  final int? id;
  final DateTime fecha;
  final bool estaPagado;
  final List<TrabajoDiaDetalle> detalles;

  const TrabajoDia({
    this.id,
    required this.fecha,
    this.estaPagado = false,
    this.detalles = const [],
  });

  TrabajoDia copyWith({
    int? id,
    DateTime? fecha,
    bool? estaPagado,
    List<TrabajoDiaDetalle>? detalles,
  }) {
    return TrabajoDia(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      estaPagado: estaPagado ?? this.estaPagado,
      detalles: detalles ?? this.detalles,
    );
  }
}
