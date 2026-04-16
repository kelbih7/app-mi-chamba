import 'package:mi_semana/features/work/domain/entities/semana_pagada.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

class MarcarSemanaComoPagada {
  final TrabajoRepositorio repositorio;

  MarcarSemanaComoPagada(this.repositorio);

  Future<void> call({
    required DateTime startOfWeek,
    required DateTime endOfWeek,
    required bool estaPagada,
  }) async {
    if (estaPagada) {
      final semana = SemanaPagada(
        inicioSemana: startOfWeek,
        finSemana: endOfWeek,
        fechaPago: DateTime.now(),
      );

      if (!semana.esRangoValido) {
        throw ArgumentError('El rango debe cubrir exactamente una semana');
      }

      await repositorio.guardarSemanaPagada(semana);
    } else {
      await repositorio.eliminarSemanaPagada(startOfWeek);
    }

    await repositorio.actualizarEstadoPagoPorRango(
      startOfWeek,
      endOfWeek,
      estaPagada,
    );
  }
}
