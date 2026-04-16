import 'package:mi_semana/features/work/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/catalog_work_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/weekly_summary_viewmodel.dart';

// -----------------------------------------------------------------------------
// APP INITIALIZER
// -----------------------------------------------------------------------------
// Esta clase se encarga de coordinar toda la inicialización de la app.
// Centraliza la carga de datos críticos antes de mostrar la UI principal.
//
// Responsabilidades:
// 1. Cargar el catálogo de trabajos (dependencia base de la app)
// 2. Inicializar el estado del calendario mensual
// 3. Cargar el resumen semanal
//
// Nota:
// No contiene lógica de negocio, solo orquestación entre ViewModels.
// -----------------------------------------------------------------------------
class AppInitializer {
  final CatalogWorkViewmodel catalogVM;
  final CalendarViewModel calendarVM;
  final WeeklySummaryViewmodel summaryVM;

  AppInitializer({
    required this.catalogVM,
    required this.calendarVM,
    required this.summaryVM,
  });

  Future<void> initialize() async {
    // Obtener la fecha actual
    final now = DateTime.now();

    // Calcular el primer día del mes actual
    final inicioMes = DateTime(now.year, now.month, 1);

    // -------------------------------------------------------------------------
    // 1. Cargar catálogo de trabajos
    // -------------------------------------------------------------------------
    // Este paso es crítico porque otras partes de la app dependen de estos datos
    await catalogVM.cargarTrabajos();

    // -------------------------------------------------------------------------
    // 2. Cargar datos en paralelo
    // -------------------------------------------------------------------------
    // Una vez que el catálogo está listo, se pueden cargar en paralelo:
    // - Estado del calendario mensual
    // - Resumen semanal
    await Future.wait([
      calendarVM.cargarMes(inicioMes),
      summaryVM.cargarResumen(inicioMes, now),
    ]);
  }
}
