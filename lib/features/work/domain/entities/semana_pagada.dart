class SemanaPagada {
  final DateTime inicioSemana;
  final DateTime finSemana;
  final DateTime fechaPago;

  const SemanaPagada({
    required this.inicioSemana,
    required this.finSemana,
    required this.fechaPago,
  });

  bool get esRangoValido {
    return finSemana.difference(inicioSemana).inDays == 6;
  }

  //opcional para verificar si una fecha esta dentro de una semana pagada
  bool fechaDentroDeSemana(DateTime fecha) {
    return !fecha.isBefore(inicioSemana) && !fecha.isAfter(finSemana);
  }
}
