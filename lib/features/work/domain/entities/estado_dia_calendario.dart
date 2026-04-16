class EstadoDiaCalendario {
  final DateTime fecha;
  final bool tieneRegistro;
  final bool estaPagado;
  final bool? semanaBloqueada;

  const EstadoDiaCalendario({
    required this.fecha,
    required this.tieneRegistro,
    required this.estaPagado,
    this.semanaBloqueada,
  });

  EstadoDiaCalendario copyWith({
    DateTime? fecha,
    bool? tieneRegistro,
    bool? estaPagado,
    bool? semanaBloqueada,
  }) {
    return EstadoDiaCalendario(
      fecha: fecha ?? this.fecha,
      tieneRegistro: tieneRegistro ?? this.tieneRegistro,
      estaPagado: estaPagado ?? this.estaPagado,
      semanaBloqueada: semanaBloqueada ?? this.semanaBloqueada,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EstadoDiaCalendario &&
        other.fecha.year == fecha.year &&
        other.fecha.month == fecha.month &&
        other.fecha.day == fecha.day &&
        other.tieneRegistro == tieneRegistro &&
        other.estaPagado == estaPagado &&
        other.semanaBloqueada == semanaBloqueada;
  }

  @override
  int get hashCode => Object.hash(
    fecha.year,
    fecha.month,
    fecha.day,
    tieneRegistro,
    estaPagado,
    semanaBloqueada,
  );
}
