class DetalleSemana {
  final int weekNumber; // solo informativo
  final bool estaPagada;
  final List<DetalleDia> dias;

  const DetalleSemana({
    required this.weekNumber,
    required this.estaPagada,
    required this.dias,
  });
}

class DetalleDia {
  final DateTime fecha;
  final double total;
  final List<DetalleActividad> actividades;

  const DetalleDia({
    required this.fecha,
    required this.total,
    required this.actividades,
  });
}

class DetalleActividad {
  final String nombre;
  final int cantidad;
  final double subtotal;
  final int colorId;
  final int iconoId;

  const DetalleActividad({
    required this.nombre,
    required this.cantidad,
    required this.subtotal,
    required this.colorId,
    required this.iconoId,
  });
}
