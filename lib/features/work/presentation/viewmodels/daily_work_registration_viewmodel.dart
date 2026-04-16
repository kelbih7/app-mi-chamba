import 'package:mi_semana/core/services/exception_handler_of_db.dart';
import 'package:mi_semana/core/state/action_state_manager.dart';
import 'package:mi_semana/core/state/base_vm_state_manager.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia_detalle.dart';
import 'package:mi_semana/features/work/domain/usecases/daily_work/actualizar_trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/usecases/daily_work/eliminar_trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/usecases/daily_work/guardar_trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/usecases/daily_work/obtener_trabajo_dia_por_fecha.dart';

/// ViewModel encargado de la gestión del registro diario de trabajos.
///
/// Responsabilidades:
/// - Cargar el trabajo de un día específico
/// - Gestionar detalles (agregar, editar, eliminar)
/// - Detectar cambios significativos
/// - Guardar, actualizar y eliminar registros
///
/// Se apoya en:
/// - [BaseVmStateManager] para estado global y mensajes
/// - [ActionStateManager] para acciones puntuales (guardar / eliminar)
/// - [ExceptionHandlerOfDb] para manejo centralizado de errores
class DailyWorkRegistrationViewmodel extends BaseVmStateManager
    with ExceptionHandlerOfDb, ActionStateManager {
  // ===============================================================
  // CASOS DE USO
  // ===============================================================

  final GuardarTrabajoDia guardarTrabajoDiaUseCase;
  final ActualizarTrabajoDia actualizarTrabajoDiaUseCase;
  final ObtenerTrabajoDiaPorFecha obtenerTrabajoDiaPorFechaUseCase;
  final EliminarTrabajoDia eliminarTrabajoDiaUseCase;

  DailyWorkRegistrationViewmodel({
    required this.guardarTrabajoDiaUseCase,
    required this.actualizarTrabajoDiaUseCase,
    required this.obtenerTrabajoDiaPorFechaUseCase,
    required this.eliminarTrabajoDiaUseCase,
  });

  // ===============================================================
  // ESTADO INTERNO
  // ===============================================================

  /// Registro actual en edición.
  TrabajoDia? _trabajoDiaActual;

  /// Copia del registro original para detectar cambios.
  TrabajoDia? _trabajoDiaOriginal;

  /// Retorna el registro actual.
  TrabajoDia? get trabajoDiaActual => _trabajoDiaActual;

  /// Retorna los detalles del día actual.
  List<TrabajoDiaDetalle> get detalles =>
      _trabajoDiaActual?.detalles ?? const [];

  /// Indica si existe un registro cargado.
  bool get tieneRegistro => _trabajoDiaActual != null;

  /// Indica si existen cambios relevantes respecto al estado original.
  bool get hayCambios => _hayCambiosSignificativos();

  /// Define si el estado actual permite ejecutar la acción de guardar.
  bool get puedeGuardar =>
      _trabajoDiaActual != null &&
      detalles.isNotEmpty &&
      _hayCambiosSignificativos();

  // ===============================================================
  // CARGA DE DATOS
  // ===============================================================

  /// Carga el trabajo correspondiente a una fecha específica.
  ///
  /// - Activa el estado de carga
  /// - Consulta el caso de uso
  /// - Guarda una copia para detección de cambios
  Future<void> cargarTrabajoDelDia(DateTime fecha) async {
    final day = _soloDia(fecha);
    isLoading = true;

    try {
      final resultado = await obtenerTrabajoDiaPorFechaUseCase(day);
      _trabajoDiaActual = resultado;
      _trabajoDiaOriginal = resultado;
    } catch (e) {
      handleException(e, operation: "cargar trabajo del día");
    } finally {
      isLoading = false;
      safeNotify();
    }
  }

  /// Inicializa el estado del ViewModel para una fecha.
  ///
  /// Limpia cualquier estado previo y luego carga la información.
  Future<void> inicializarParaFecha(DateTime fecha) async {
    resetState();
    await cargarTrabajoDelDia(fecha);
  }

  // ===============================================================
  // MANIPULACIÓN DE DETALLES
  // ===============================================================

  /// Agrega un nuevo detalle al día actual.
  void agregarDetalle(TrabajoDiaDetalle detalle, DateTime fechaSeleccionada) {
    final nuevosDetalles = [...detalles, detalle];

    _trabajoDiaActual =
        (_trabajoDiaActual ?? TrabajoDia(fecha: _soloDia(fechaSeleccionada)))
            .copyWith(detalles: nuevosDetalles);

    safeNotify();
  }

  /// Actualiza un detalle existente identificado por [trabajoId].
  void actualizarDetalle(int trabajoId, TrabajoDiaDetalle nuevo) {
    if (_trabajoDiaActual == null) return;

    final nuevosDetalles = detalles
        .map((d) => d.trabajoId == trabajoId ? nuevo : d)
        .toList();

    _trabajoDiaActual = _trabajoDiaActual!.copyWith(detalles: nuevosDetalles);
    safeNotify();
  }

  /// Elimina un detalle del día actual.
  void eliminarDetalle(int trabajoId) {
    if (_trabajoDiaActual == null) return;

    final nuevosDetalles = detalles
        .where((d) => d.trabajoId != trabajoId)
        .toList();

    _trabajoDiaActual = _trabajoDiaActual!.copyWith(detalles: nuevosDetalles);
    safeNotify();
  }

  // ===============================================================
  // GUARDAR / ACTUALIZAR
  // ===============================================================

  /// Guarda o actualiza el registro diario.
  ///
  /// - Valida cambios
  /// - Activa estado de guardado
  /// - Ejecuta el caso de uso correspondiente
  /// - Emite mensaje one-shot
  Future<bool> guardarTrabajoDia() async {
    final actual = _trabajoDiaActual;
    if (actual == null) return false;

    if (!_hayCambiosSignificativos()) {
      emitMessage("No hay cambios para guardar", success: false);
      return false;
    }

    setSaving(true);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final esNuevo = actual.id == null;

      final guardado = esNuevo
          ? await guardarTrabajoDiaUseCase(actual)
          : await actualizarTrabajoDiaUseCase(actual);

      _trabajoDiaActual = guardado;
      _trabajoDiaOriginal = guardado;

      emitMessage("Registro diario guardado correctamente", success: true);

      safeNotify();
      return true;
    } catch (e) {
      handleException(e, operation: "guardar trabajo del día");
      return false;
    } finally {
      setSaving(false);
    }
  }

  // ===============================================================
  // ELIMINAR
  // ===============================================================

  /// Elimina completamente el registro del día actual.
  Future<bool> eliminarTodosLosTrabajos() async {
    final id = _trabajoDiaActual?.id;
    if (id == null) return false;

    setDeleting(true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      await eliminarTrabajoDiaUseCase(id);

      _trabajoDiaActual = null;
      _trabajoDiaOriginal = null;

      emitMessage(
        "Todos los trabajos del día fueron eliminados",
        success: true,
      );

      safeNotify();
      return true;
    } catch (e) {
      handleException(e, operation: "eliminar trabajos del día");
      return false;
    } finally {
      setDeleting(false);
    }
  }

  // ===============================================================
  // DETECCIÓN DE CAMBIOS
  // ===============================================================

  /// Determina si existen cambios relevantes entre el estado
  /// original y el actual.
  bool _hayCambiosSignificativos() {
    final actual = _trabajoDiaActual;
    final original = _trabajoDiaOriginal;

    if (original == null && actual != null) {
      return actual.detalles.isNotEmpty;
    }

    if (actual == null || original == null) return false;

    if (actual.detalles.length != original.detalles.length) {
      return true;
    }

    final originalMap = {for (final d in original.detalles) d.trabajoId: d};

    for (final d in actual.detalles) {
      final old = originalMap[d.trabajoId];
      if (old == null) return true;

      if (old.cantidad != d.cantidad || old.pago != d.pago) {
        return true;
      }
    }

    return false;
  }

  // ===============================================================
  // RESET
  // ===============================================================

  /// Restablece completamente el estado del ViewModel.
  @override
  void resetState() {
    super.resetState();
    _trabajoDiaActual = null;
    _trabajoDiaOriginal = null;
  }

  /// Normaliza una fecha eliminando hora/minutos.
  DateTime _soloDia(DateTime d) => DateTime(d.year, d.month, d.day);
}
