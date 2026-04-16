import '../../repositories/trabajo_repositorio.dart';
import '../../entities/trabajo_catalogo.dart';

class ActualizarTrabajo {
  final TrabajoRepositorio repositorio;

  ActualizarTrabajo(this.repositorio);

  /// Actualiza el trabajo y devuelve la entidad actualizada.
  Future<Trabajo> call(Trabajo trabajo) async {
    return await repositorio.actualizarTrabajo(trabajo);
  }
}
