import 'package:mi_semana/core/services/exception_handler_of_db.dart';
import 'package:mi_semana/core/state/action_state_manager.dart';
import 'package:mi_semana/core/state/base_vm_state_manager.dart';
import 'package:mi_semana/features/work/domain/entities/detalle_semana.dart';
import 'package:mi_semana/features/work/domain/usecases/marcar_semana_como_pagada.dart';
import 'package:mi_semana/features/work/domain/usecases/obtener_detalle_semanal.dart';
import 'package:mi_semana/features/work/domain/usecases/verificar_semana_pagada.dart';

class WeeklyDetailViewmodel extends BaseVmStateManager
    with ActionStateManager, ExceptionHandlerOfDb {
  final ObtenerDetalleSemanal obtenerDetalleSemanal;
  final MarcarSemanaComoPagada marcarSemanaComoPagada;
  final VerificarSemanaPagada verificarSemanaPagada;

  WeeklyDetailViewmodel(
    this.obtenerDetalleSemanal,
    this.marcarSemanaComoPagada,
    this.verificarSemanaPagada,
  );

  /// Detalle visible de la semana
  DetalleSemana? semana;

  /// RANGO REAL DE LA SEMANA (lunes → domingo)
  DateTime? inicioSemana;
  DateTime? finSemana;

  //prueba:
  bool semanaBloqueada = false;

  // ===========================================================================
  // CARGAR SEMANA
  // ===========================================================================

  Future<void> cargarSemana(
    DateTime start,
    DateTime end,
    int weekNumber,
  ) async {
    isLoading = true;

    try {
      //prueba
      semanaBloqueada = await verificarSemanaPagada(start);
      inicioSemana = start;
      finSemana = end;

      final result = await obtenerDetalleSemanal(
        inicio: start,
        fin: end,
        weekNumber: weekNumber,
      );

      semana = result;
    } catch (e) {
      handleException(e, operation: "cargar resumen semanal");
    } finally {
      isLoading = false;
      safeNotify();
    }
  }

  // ===========================================================================
  // CAMBIAR ESTADO DE PAGO DE LA SEMANA
  // ===========================================================================

  Future<bool> cambiarEstadoPagoSemana(bool nuevoEstado) async {
    if (semana == null || inicioSemana == null || finSemana == null) {
      return false;
    }

    setSaving(true);

    try {
      await marcarSemanaComoPagada(
        startOfWeek: inicioSemana!,
        endOfWeek: finSemana!,
        estaPagada: nuevoEstado,
      );

      // Recargar detalle semanal
      final result = await obtenerDetalleSemanal(
        inicio: inicioSemana!,
        fin: finSemana!,
        weekNumber: semana!.weekNumber,
      );

      semana = result;

      emitMessage(
        nuevoEstado
            ? "Semana marcada como pagada"
            : "Semana marcada como pendiente",
        success: true,
      );

      safeNotify();
      return true;
    } catch (e) {
      handleException(e, operation: "cambiar estado de pago de semana");
      return false;
    } finally {
      setSaving(false);
    }
  }
}
