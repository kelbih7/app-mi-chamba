import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

class ObtenerTrabajoDiaPorFecha {
  final TrabajoRepositorio repositorio;

  ObtenerTrabajoDiaPorFecha(this.repositorio);

  Future<TrabajoDia?> call(DateTime fecha) async {
    return await repositorio.obtenerTrabajoDiaPorFecha(fecha);
  }
}
