import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

class EliminarTrabajoDia {
  final TrabajoRepositorio repositorio;
  //verificar semana pagada, pero espera fecha.

  EliminarTrabajoDia(this.repositorio);

  /// Elimina por id y devuelve el número de filas afectadas (0 si no existía).
  Future<void> call(int id) async {
    return await repositorio.eliminarTrabajoDia(id);
  }
}
