import 'package:mi_semana/core/exceptions/domain_exception.dart';
import 'package:mi_semana/features/work/domain/usecases/verificar_semana_pagada.dart';

import '../../repositories/trabajo_repositorio.dart';
import '../../entities/trabajo_dia.dart';

class GuardarTrabajoDia {
  final TrabajoRepositorio repositorio;
  final VerificarSemanaPagada verificarSemanaPagada;

  GuardarTrabajoDia(this.repositorio, this.verificarSemanaPagada);
  Future<TrabajoDia> call(TrabajoDia trabajoDia) async {
    final semBloqueada = await verificarSemanaPagada(trabajoDia.fecha);
    if (semBloqueada) {
      throw const DomainException('SEMANA_PAGADA');
    }
    return await repositorio.agregarTrabajoDia(trabajoDia);
  }
}
