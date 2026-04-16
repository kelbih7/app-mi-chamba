import 'package:mi_semana/core/state/base_vm_state_manager.dart';

/// Mixin para manejo centralizado de excepciones relacionadas a base de datos.
///
/// Responsabilidad:
/// - Traducir errores técnicos en mensajes entendibles para la UI
/// - Marcar el estado de error del ViewModel
///
/// No maneja lifecycle, loading ni notificaciones directas.
/// Confía completamente en [BaseVmStateManager].
mixin ExceptionHandlerOfDb on BaseVmStateManager {
  /// Maneja una excepción y emite un mensaje amigable para el usuario.
  ///
  /// [error] Excepción capturada.
  /// [fallback] Mensaje genérico en caso de error no reconocido.
  /// [operation] Contexto lógico de la operación fallida.
  void handleException(
    dynamic error, {
    String fallback = "Ocurrió un error",
    String operation = "operación",
  }) {
    final errorMsg = error.toString();
    late final String message;

    if (errorMsg.contains('UNIQUE constraint failed')) {
      message = "Ya existe un registro con los mismos datos";
    } else if (errorMsg.contains('FOREIGN KEY constraint failed')) {
      message =
          "No se puede completar la acción porque el registro está en uso";
    } else if (errorMsg.contains('NOT NULL constraint failed')) {
      message = "Faltan datos obligatorios para completar la operación";
    } else if (errorMsg.contains('no such table')) {
      message = "Error interno de configuración de la base de datos";
    } else if (errorMsg.contains('database is closed')) {
      message = "La base de datos no está disponible en este momento";
    } else {
      message = "$fallback al intentar $operation";
    }

    /// Evento one-shot para la UI
    emitMessage(message, success: false);

    /// Estado persistente de error
    hasError = true;
  }
}
