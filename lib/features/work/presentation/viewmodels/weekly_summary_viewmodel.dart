import 'package:mi_semana/core/services/exception_handler_of_db.dart';
import 'package:mi_semana/core/state/action_state_manager.dart';
import 'package:mi_semana/core/state/base_vm_state_manager.dart';
import 'package:mi_semana/features/work/domain/entities/resumen_semana.dart';
import 'package:mi_semana/features/work/domain/usecases/obtener_resumen_semanal.dart';

/// ViewModel encargado del resumen semanal.
///
/// Responsabilidades:
/// - Cargar resúmenes semanales
/// - Exponer catálogo de trabajos (solo lectura)
/// - Gestionar acciones de la semana (marcar pagada / pendiente)
/// - Compartir estados de acción con la UI (saving)
///
/// Se apoya en:
/// - [BaseVmStateManager] para estado global
/// - [ActionStateManager] para acciones puntuales
/// - [ExceptionHandlerOfDb] para manejo de errores
class WeeklySummaryViewmodel extends BaseVmStateManager
    with ExceptionHandlerOfDb, ActionStateManager {
  // ===============================================================
  // CASOS DE USO / DEPENDENCIAS
  // ===============================================================

  final ObtenerResumenSemanal obtenerResumenSemanalUseCase;

  WeeklySummaryViewmodel({required this.obtenerResumenSemanalUseCase});

  // ===============================================================
  // ESTADO INTERNO
  // ===============================================================

  List<ResumenSemana> _resumenSemanas = [];

  // ===============================================================
  // GETTERS
  // ===============================================================

  List<ResumenSemana> get resumenSemanas => _resumenSemanas;

  bool get tieneDatos => _resumenSemanas.isNotEmpty;

  // ===============================================================
  // CARGA DE DATOS
  // ===============================================================

  /// Carga los resúmenes semanales para un rango de fechas.
  Future<void> cargarResumen(DateTime inicio, DateTime fin) async {
    isLoading = true;

    try {
      final nuevos = await obtenerResumenSemanalUseCase(inicio, fin);
      _resumenSemanas = List.from(nuevos);
    } catch (e) {
      _resumenSemanas = [];
      handleException(
        e,
        fallback: 'Error cargando resumen semanal',
        operation: 'obtener resumen semanal',
      );
    } finally {
      isLoading = false;
      safeNotify();
    }
  }

  // ===============================================================
  // RESET
  // ===============================================================

  /// Limpia completamente el estado del ViewModel.
  @override
  void resetState() {
    super.resetState();
    _resumenSemanas = [];
  }
}
