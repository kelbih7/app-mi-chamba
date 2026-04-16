class TrabajoDiaDetalleModel {
  final int? id;
  final int trabajoDiaId;
  final int trabajoId;
  final int cantidad;
  final double pago;

  const TrabajoDiaDetalleModel({
    this.id,
    required this.trabajoDiaId,
    required this.trabajoId,
    required this.cantidad,
    required this.pago,
  });

  factory TrabajoDiaDetalleModel.fromMap(Map<String, dynamic> map) {
    return TrabajoDiaDetalleModel(
      id: map['id'] as int?,
      trabajoDiaId: map['trabajo_dia_id'] as int,
      trabajoId: map['trabajo_id'] as int,
      cantidad: map['cantidad'] as int,
      pago: (map['pago'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trabajo_dia_id': trabajoDiaId,
      'trabajo_id': trabajoId,
      'cantidad': cantidad,
      'pago': pago,
    };
  }
}
