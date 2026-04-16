import 'package:mi_semana/features/work/domain/entities/detalle_semana.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_catalogo.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

/// ===============================================================
/// Caso de uso:
/// Construye el detalle completo de una semana de trabajo.
///
/// Responsabilidad:
/// - Obtener datos crudos desde el repositorio
/// - Cruzar entidades (días ↔ trabajos)
/// - Calcular subtotales y totales
/// - Retornar un modelo listo para consumo por la UI
///
/// ===============================================================
class ObtenerDetalleSemanal {
  final TrabajoRepositorio repository;

  /// Inyección del repositorio (Clean Architecture)
  ObtenerDetalleSemanal(this.repository);

  /// ---------------------------------------------------------------
  /// Método público del caso de uso
  ///
  /// Orquesta la obtención de datos y delega la construcción del
  /// modelo de salida.
  ///
  /// - [inicio] y [fin]: rango de fechas de la semana
  /// - [weekNumber]: número de la semana (dato contextual)
  /// ---------------------------------------------------------------
  Future<DetalleSemana> call({
    required DateTime inicio,
    required DateTime fin,
    required int weekNumber,
  }) async {
    // Obtiene los días trabajados dentro del rango
    final dias = await repository.obtenerTrabajosDiaPorRango(inicio, fin);

    // Obtiene el catálogo completo de trabajos
    final trabajos = await repository.obtenerTrabajos();

    // Construye el modelo final de la semana
    return _construirDetalleSemana(
      weekNumber: weekNumber,
      dias: dias,
      trabajos: trabajos,
    );
  }

  /// ---------------------------------------------------------------
  /// Construye el modelo DetalleSemana a partir de datos crudos
  ///
  /// Responsabilidades:
  /// - Cruzar TrabajoDia ↔ Trabajo
  /// - Calcular subtotales por actividad
  /// - Calcular total por día
  /// - Determinar si la semana está completamente pagada
  ///
  /// Este método es privado porque:
  /// - No representa un caso de uso independiente
  /// - Es un detalle de implementación
  /// ---------------------------------------------------------------
  DetalleSemana _construirDetalleSemana({
    required int weekNumber,
    required List<TrabajoDia> dias,
    required List<Trabajo> trabajos,
  }) {
    // Mapa para acceso O(1) a los trabajos por ID
    // Evita búsquedas lineales repetidas en la UI o lógica superior
    final trabajosMap = {for (final trabajo in trabajos) trabajo.id!: trabajo};

    // Construcción del detalle por día
    final detalleDias = dias.map((dia) {
      // Construcción de actividades del día
      final actividades = dia.detalles.map((detalle) {
        // Obtiene el trabajo asociado al detalle
        final trabajo = trabajosMap[detalle.trabajoId]!;

        // Subtotal = cantidad * pago del detalle
        // Regla de negocio: el pago viene del detalle,
        // no necesariamente del catálogo
        final subtotal = detalle.cantidad * detalle.pago;

        // Modelo plano, listo para la UI
        // Se pasan IDs semánticos (colorId, iconoId)
        return DetalleActividad(
          nombre: trabajo.nombre,
          cantidad: detalle.cantidad,
          subtotal: subtotal,
          colorId: trabajo.color,
          iconoId: trabajo.icono,
        );
      }).toList();

      // Total del día = suma de subtotales
      final totalDia = actividades.fold<double>(
        0,
        (sum, a) => sum + a.subtotal,
      );

      // Retorna el día completamente construido
      return DetalleDia(
        fecha: dia.fecha,
        total: totalDia,
        actividades: actividades,
      );
    }).toList();

    // La semana se considera pagada solo si:
    // - Tiene días
    // - Todos los días están marcados como pagados
    final estaPagada = dias.isNotEmpty && dias.every((d) => d.estaPagado);

    // Retorna el modelo final de la semana
    return DetalleSemana(
      weekNumber: weekNumber,
      estaPagada: estaPagada,
      dias: detalleDias,
    );
  }
}
