/// Representa los detalles de un día trabajado
class TrabajoDiaDetalle {
  final int? id;
  final int trabajoId;
  final int cantidad;
  final double pago;

  const TrabajoDiaDetalle({
    this.id,
    required this.trabajoId,
    this.cantidad = 1,
    required this.pago,
  });

  TrabajoDiaDetalle copyWith({
    int? id,
    int? trabajoId,
    int? cantidad,
    double? pago,
  }) {
    return TrabajoDiaDetalle(
      id: id ?? this.id,
      trabajoId: trabajoId ?? this.trabajoId,
      cantidad: cantidad ?? this.cantidad,
      pago: pago ?? this.pago,
    );
  }
}
