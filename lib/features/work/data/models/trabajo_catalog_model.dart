import 'package:mi_semana/features/work/domain/entities/trabajo_catalogo.dart';

class TrabajoCatalogoModel extends Trabajo {
  TrabajoCatalogoModel({
    super.id,
    required super.nombre,
    required super.pagoPredeterminado,
    required super.color,
    required super.icono,
  });

  factory TrabajoCatalogoModel.fromMap(Map<String, dynamic> map) {
    return TrabajoCatalogoModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      pagoPredeterminado: (map['pago_predeterminado'] as num).toDouble(),
      color: map['color'] as int,
      icono: map['icono'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'pago_predeterminado': pagoPredeterminado,
      'color': color,
      'icono': icono,
    };
  }
}
