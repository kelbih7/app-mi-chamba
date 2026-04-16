///Catálogo de tipos de trabajo (Cargar, Descargar, etc.)
class Trabajo {
  final int? id;
  final String nombre;
  final double pagoPredeterminado;
  final int color; // id del color
  final int icono; // id del icono

  const Trabajo({
    this.id,
    required this.nombre,
    required this.pagoPredeterminado,
    required this.color,
    required this.icono,
  });

  Trabajo copyWith({
    int? id,
    String? nombre,
    double? pagoPredeterminado,
    int? color,
    int? icono,
  }) {
    return Trabajo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      pagoPredeterminado: pagoPredeterminado ?? this.pagoPredeterminado,
      color: color ?? this.color,
      icono: icono ?? this.icono,
    );
  }
}
