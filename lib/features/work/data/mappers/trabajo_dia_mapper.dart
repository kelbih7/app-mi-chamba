import 'package:mi_semana/features/work/data/models/trabajo_dia_model.dart';
import 'package:mi_semana/features/work/data/models/trabajo_dia_detalle_model.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';

extension TrabajoDiaMapper on TrabajoDia {
  TrabajoDiaModel toModel() {
    return TrabajoDiaModel(
      id: id,
      fecha: fecha,
      estaPagado: estaPagado,
      detalles: detalles.map((d) {
        return TrabajoDiaDetalleModel(
          id: d.id,
          trabajoDiaId: id ?? 0, // se ignora en insert, se reemplaza luego
          trabajoId: d.trabajoId,
          cantidad: d.cantidad,
          pago: d.pago,
        );
      }).toList(),
    );
  }
}
