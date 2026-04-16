import 'package:mi_semana/features/work/data/models/trabajo_dia_model.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia_detalle.dart';

extension TrabajoDiaModelMapper on TrabajoDiaModel {
  TrabajoDia toEntity() {
    return TrabajoDia(
      id: id,
      fecha: fecha,
      estaPagado: estaPagado,
      detalles: detalles.map((d) {
        return TrabajoDiaDetalle(
          id: d.id,
          trabajoId: d.trabajoId,
          cantidad: d.cantidad,
          pago: d.pago,
        );
      }).toList(),
    );
  }
}
