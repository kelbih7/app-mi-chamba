import 'package:mi_semana/core/utils/date_day_mapper.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

class VerificarRegistroAyer {
  final TrabajoRepositorio repository;

  VerificarRegistroAyer(this.repository);

  Future<bool> call() async {
    final hoy = DateDayMapper.toLocalDay(DateTime.now());

    final ayer = hoy.subtract(const Duration(days: 1));

    final trabajo = await repository.obtenerTrabajoDiaPorFecha(ayer);

    return trabajo != null;
  }
}
