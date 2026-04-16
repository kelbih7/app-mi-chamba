import 'package:mi_semana/core/services/exception_handler_of_db.dart';
import 'package:mi_semana/core/state/action_state_manager.dart';
import 'package:mi_semana/core/state/base_vm_state_manager.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_catalogo.dart';
import 'package:mi_semana/features/work/domain/usecases/work/actualizar_trabajo.dart';
import 'package:mi_semana/features/work/domain/usecases/work/agregar_trabajo.dart';
import 'package:mi_semana/features/work/domain/usecases/work/eliminar_trabajo.dart';
import 'package:mi_semana/features/work/domain/usecases/work/obtener_trabajos.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/weekly_summary_viewmodel.dart';

/// ViewModel encargado de gestionar el catálogo de trabajos.
///
/// Actúa como intermediario entre la capa de presentación (UI)
/// y la capa de dominio, coordinando las operaciones CRUD
/// relacionadas con la entidad [Trabajo].
///
/// ### Responsabilidades
/// - Ejecutar casos de uso del dominio.
/// - Mantener y exponer estado observable para la UI.
/// - Traducir resultados del dominio a estados de interfaz.
/// - Centralizar el manejo de mensajes y feedback al usuario.
///
/// ### No responsabilidades
/// - Persistencia de datos.
/// - Validaciones complejas de negocio.
/// - Lógica de navegación o composición de UI.
///
/// Este ViewModel sigue un flujo claro:
/// 1. La UI dispara una acción.
/// 2. El ViewModel ejecuta un caso de uso.
/// 3. El dominio retorna datos o lanza excepciones.
/// 4. El ViewModel actualiza estado y emite mensajes.
/// 5. La UI reacciona únicamente al estado expuesto.
class CatalogWorkViewmodel extends BaseVmStateManager
    with ActionStateManager, ExceptionHandlerOfDb {
  // ===============================================================
  // CASOS DE USO (INYECCIÓN DE DEPENDENCIAS)
  // ===============================================================

  /// Caso de uso encargado de obtener el listado de trabajos.
  ///
  /// El ViewModel no conoce la implementación concreta,
  /// solo ejecuta el contrato definido por el dominio.
  final ObtenerTrabajos obtenerTrabajosUseCase;

  /// Caso de uso encargado de agregar un nuevo trabajo.
  final AgregarTrabajo agregarTrabajoUseCase;

  /// Caso de uso encargado de actualizar un trabajo existente.
  final ActualizarTrabajo actualizarTrabajoUseCase;

  /// Caso de uso encargado de eliminar un trabajo.
  final EliminarTrabajo eliminarTrabajoUseCase;

  // ===============================================================
  // REFERENCIA OPCIONAL A OTRO VIEWMODEL
  // ===============================================================

  /// Referencia opcional a [WeeklySummaryViewmodel].
  ///
  /// Permite coordinar efectos colaterales entre pantallas,
  /// como refrescar un resumen semanal después de una operación.
  ///
  /// Se mantiene opcional para evitar acoplamientos fuertes
  /// entre ViewModels.
  WeeklySummaryViewmodel? weeklySummaryViewmodel;

  /// Crea una instancia de [CatalogWorkViewmodel].
  ///
  /// Tods los casos de uso son obligatorios para garantizar
  /// que el ViewModel pueda cumplir sus responsabilidades.
  CatalogWorkViewmodel({
    required this.obtenerTrabajosUseCase,
    required this.agregarTrabajoUseCase,
    required this.actualizarTrabajoUseCase,
    required this.eliminarTrabajoUseCase,
  });

  // ===============================================================
  // ESTADO LOCAL
  // ===============================================================

  /// Fuente de verdad del listado de trabajos.
  ///
  /// Este estado es privado y solo puede ser modificado
  /// internamente por el ViewModel.
  List<Trabajo> _trabajos = [];

  /// Retorna el listado actual de trabajos.
  ///
  /// La UI puede leer este estado, pero nunca modificarlo
  /// directamente.
  List<Trabajo> get trabajos => _trabajos;

  // ===============================================================
  // OPERACIONES CRUD
  // ===============================================================

  /// Carga el listado de trabajos desde el dominio.
  ///
  /// ### Flujo
  /// 1. Activa el estado global de carga.
  /// 2. Ejecuta el caso de uso correspondiente.
  /// 3. Actualiza el estado local con los resultados.
  /// 4. Maneja errores y emite mensajes de UI.
  ///
  /// El estado de carga se desactiva siempre,
  /// independientemente del resultado.
  Future<void> cargarTrabajos() async {
    isLoading = true;
    try {
      final result = await obtenerTrabajosUseCase();
      _trabajos = result;
    } catch (e) {
      handleException(e, operation: "cargar trabajos");
    } finally {
      isLoading = false;
      safeNotify();
    }
  }

  /// Agrega un nuevo trabajo.
  ///
  /// ### Flujo
  /// - Activa el estado de guardado (`isSaving`).
  /// - Ejecuta el caso de uso de creación.
  /// - Actualiza la lista local si la operación es exitosa.
  /// - Emite un mensaje de resultado para la UI.
  ///
  /// El estado de guardado se limpia al finalizar la operación.
  Future<bool> agregarTrabajo(Trabajo trabajo) async {
    setSaving(true);
    await Future.delayed(const Duration(milliseconds: 250));
    try {
      final creado = await agregarTrabajoUseCase(trabajo);
      _trabajos.add(creado);

      emitMessage("Trabajo guardado correctamente", success: true);
      safeNotify();
      return true;
    } catch (e) {
      handleException(e, operation: "guardar trabajo");
      return false;
    } finally {
      setSaving(false);
    }
  }

  /// Actualiza un trabajo existente.
  ///
  /// ### Flujo
  /// - Activa el estado de guardado.
  /// - Ejecuta el caso de uso de actualización.
  /// - Sincroniza el estado local si el trabajo existe.
  /// - Emite un mensaje indicando el resultado.
  Future<bool> actualizarTrabajo(Trabajo trabajo) async {
    setSaving(true);

    try {
      await Future.delayed(const Duration(milliseconds: 10));

      final actualizado = await actualizarTrabajoUseCase(trabajo);
      final index = _trabajos.indexWhere((t) => t.id == actualizado.id);

      if (index != -1) {
        _trabajos[index] = actualizado;
      }

      emitMessage("Trabajo actualizado correctamente", success: true);
      safeNotify();
      return true;
    } catch (e) {
      handleException(e, operation: "actualizartrabajo");
      return false;
    } finally {
      setSaving(false);
    }
  }

  /// Elimina un trabajo por su identificador.
  ///
  /// ### Flujo
  /// - Activa el estado de eliminación (`isDeleting`).
  /// - Ejecuta el caso de uso de eliminación.
  /// - Valida si se afectaron filas.
  /// - Actualiza el estado local y emite el mensaje correspondiente.
  ///
  /// El estado de eliminación se limpia al finalizar.
  Future<bool> eliminarTrabajo(int id) async {
    setDeleting(true);
    await Future.delayed(const Duration(seconds: 1));
    try {
      final rows = await eliminarTrabajoUseCase(id);
      if (rows > 0) {
        _trabajos.removeWhere((t) => t.id == id);
        emitMessage("Trabajo eliminado correctamente", success: true);
        safeNotify();
        return true;
      } else {
        emitMessage("No se puedo eliminar al trabajo", success: false);
        return false;
      }
    } catch (e) {
      handleException(e, operation: "eliminar trabajo");
      return false;
    } finally {
      setDeleting(false);
    }
  }

  // ===============================================================
  // RESET DE ESTADO
  // ===============================================================

  /// Restablece el estado completo del ViewModel.
  ///
  /// Se utiliza cuando el ViewModel debe volver a un estado limpio,
  /// por ejemplo:
  /// - Cierre de sesión.
  /// - Cambio de contexto.
  /// - Limpieza manual de datos en memoria.
  @override
  void resetState() {
    super.resetState();
    _trabajos.clear();
  }
}
