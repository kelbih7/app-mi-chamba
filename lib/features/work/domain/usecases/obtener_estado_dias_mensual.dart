import '../repositories/trabajo_repositorio.dart';
import '../entities/estado_dia_calendario.dart';

class ObtenerEstadoDiasMensual {
  final TrabajoRepositorio repositorio;

  ObtenerEstadoDiasMensual(this.repositorio);

  Future<List<EstadoDiaCalendario>> call(DateTime mes) async {
    return await repositorio.obtenerEstadoDiasPorMes(mes);
  }
}
