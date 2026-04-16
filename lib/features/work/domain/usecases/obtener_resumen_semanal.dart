import 'package:mi_semana/core/utils/week_domain_helper.dart';
import 'package:mi_semana/features/work/domain/entities/resumen_semana.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

/// Caso de uso encargado de construir el resumen semanal de trabajos
/// dentro de un rango de fechas determinado (normalmente un mes).
class ObtenerResumenSemanal {
  /// Repositorio que provee el acceso a los datos de trabajo y días trabajados.
  final TrabajoRepositorio repositorio;

  ObtenerResumenSemanal(this.repositorio);

  /// Ejecuta el caso de uso.
  ///
  /// [inicioMes] y [finMes] definen el rango de fechas a evaluar.
  /// Retorna una lista de [ResumenSemana], ordenada cronológicamente.
  Future<List<ResumenSemana>> call(DateTime inicioMes, DateTime finMes) async {
    /// Obtiene todos los días trabajados dentro del rango solicitado.
    final diasTrabajados = await repositorio.obtenerTrabajosDiaPorRango(
      inicioMes,
      finMes,
    );

    /// Obtiene el catálogo completo de trabajos.
    /// Se usa para construir un mapeo de id → inicial del nombre.
    final catalogo = await repositorio.obtenerTrabajos();

    /// Mapa que relaciona el id del trabajo con su inicial.
    /// Ejemplo: { 1: 'A', 2: 'B' }
    final Map<int, String> trabajoIdToInicial = {
      for (var t in catalogo)
        if (t.id != null) t.id!: t.nombre[0].toUpperCase(),
    };

    /// Agrupa los días trabajados por número de semana ISO.
    /// La clave es el número de semana y el valor la lista de días de esa semana.
    final Map<int, List<TrabajoDia>> semanasMap = {};

    for (var dia in diasTrabajados) {
      final weekNumber = WeekDomainHelper.weekNumber(dia.fecha);
      semanasMap.putIfAbsent(weekNumber, () => []).add(dia);
    }

    /// Lista final que contendrá los resúmenes semanales construidos.
    final List<ResumenSemana> resumenSemanas = [];

    /// Recorre cada semana y construye su respectivo resumen.
    semanasMap.forEach((weekNumber, diasSemana) {
      double totalSemana = 0;
      bool estaPagada = true;

      /// Contador de actividades por inicial.
      /// Ejemplo: { 'A': 3, 'B': 2 }
      final Map<String, int> actividadesCount = {};

      /// Calcula el rango real de la semana (lunes → domingo)
      /// usando el helper de dominio.
      final referencia = diasSemana.first.fecha;

      final startOfWeek = WeekDomainHelper.startOfWeek(referencia);
      final endOfWeek = WeekDomainHelper.endOfWeek(referencia);

      /// Recorre cada día de la semana para calcular totales y estados.
      for (var dia in diasSemana) {
        for (var detalle in dia.detalles) {
          /// Suma el pago total del detalle (pago unitario * cantidad).
          totalSemana += detalle.pago * detalle.cantidad;

          /// Obtiene la inicial del trabajo.
          /// Si no existe, se usa 'X' como valor por defecto.
          final inicial = trabajoIdToInicial[detalle.trabajoId] ?? 'X';

          /// Acumula la cantidad por tipo de trabajo.
          actividadesCount[inicial] =
              (actividadesCount[inicial] ?? 0) + detalle.cantidad;
        }

        /// Si al menos un día no está pagado,
        /// la semana completa se marca como no pagada.
        if (!dia.estaPagado) {
          estaPagada = false;
        }
      }

      /// Construye el resumen textual de actividades.
      /// Ejemplo: "3A + 2B"
      final resumenActividades = actividadesCount.entries
          .map((e) => '${e.value}${e.key}')
          .join(' + ');

      /// Crea el objeto de dominio [ResumenSemana] y lo agrega a la lista.
      resumenSemanas.add(
        ResumenSemana(
          weekNumber: weekNumber,
          startDate: startOfWeek,
          endDate: endOfWeek,
          estaPagada: estaPagada,
          resumenActividades: resumenActividades,
          total: totalSemana,
          dias: diasSemana,
        ),
      );
    });

    /// Ordena los resúmenes por fecha de inicio de semana,
    /// garantizando una secuencia cronológica correcta.
    resumenSemanas.sort((a, b) => a.startDate.compareTo(b.startDate));

    return resumenSemanas;
  }
}
