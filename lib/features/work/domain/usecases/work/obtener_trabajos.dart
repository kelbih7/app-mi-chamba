import '../../repositories/trabajo_repositorio.dart';
import '../../entities/trabajo_catalogo.dart';

class ObtenerTrabajos {
  final TrabajoRepositorio repositorio;

  ObtenerTrabajos(this.repositorio);

  Future<List<Trabajo>> call() async {
    return await repositorio.obtenerTrabajos();
  }
}
