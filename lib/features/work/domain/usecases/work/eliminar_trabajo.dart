import '../../repositories/trabajo_repositorio.dart';

class EliminarTrabajo {
  final TrabajoRepositorio repositorio;

  EliminarTrabajo(this.repositorio);

  /// Elimina por id y devuelve el número de filas afectadas (0 si no existía).
  Future<int> call(int id) async {
    return await repositorio.eliminarTrabajo(id);
  }
}
