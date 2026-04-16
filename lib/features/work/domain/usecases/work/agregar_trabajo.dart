import '../../repositories/trabajo_repositorio.dart';
import '../../entities/trabajo_catalogo.dart';

class AgregarTrabajo {
  final TrabajoRepositorio repositorio;

  AgregarTrabajo(this.repositorio);

  /// Persiste el trabajo y devuelve la entidad creada (con id asignado por la BD).
  Future<Trabajo> call(Trabajo trabajo) async {
    return await repositorio.agregarTrabajo(trabajo);
  }
}
