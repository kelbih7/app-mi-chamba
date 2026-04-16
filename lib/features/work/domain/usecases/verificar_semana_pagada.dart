import 'package:mi_semana/core/utils/week_domain_helper.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

class VerificarSemanaPagada {
  final TrabajoRepositorio repository;

  VerificarSemanaPagada(this.repository);

  Future<bool> call(DateTime fecha) {
    final lunes = WeekDomainHelper.startOfWeek(fecha);
    return repository.estaSemanaBloqueada(lunes);
  }
}
