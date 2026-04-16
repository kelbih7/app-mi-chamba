import 'package:flutter/material.dart';
import 'package:mi_semana/core/state/dispose_safe_notifier.dart';
import 'package:mi_semana/core/ui/ui_message.dart';

/// Clase base abstracta para todos los ViewModels de la aplicación.
///
/// Define y centraliza el **estado común transversal** que puede ser
/// compartido por cualquier ViewModel, independientemente del feature.
///
/// Está construida sobre [SafeChangeNotifier], por lo que:
/// - Todos los cambios de estado son seguros frente a `dispose`.
/// - Evita errores del tipo *setState / notifyListeners after dispose*.
///
/// ## Responsabilidades
/// - Estado global de carga
/// - Estado global de error
/// - Emisión de mensajes de UI de tipo one-shot
/// - Reset estándar del estado
///
/// ## Lo que NO hace
/// - No contiene lógica de negocio
/// - No conoce detalles de base de datos
/// - No maneja estados de acciones específicas (guardar, eliminar)
///
/// Cada ViewModel concreto debe extender esta clase y construir
/// su propio estado encima de ella.
abstract class BaseVmStateManager extends SafeChangeNotifier {
  // ===============================================================
  // ESTADO GENERAL
  // ===============================================================

  /// Indica si el ViewModel se encuentra ejecutando una operación global.
  ///
  /// Se utiliza típicamente para:
  /// - Mostrar loaders de pantalla completa
  /// - Bloquear la interacción general de la vista
  bool _isLoading = false;

  /// Indica si ocurrió un error durante la última operación.
  ///
  /// No contiene el detalle del error, solo el flag de estado.
  bool _hasError = false;

  /// Retorna si el estado actual es de carga.
  bool get isLoading => _isLoading;

  /// Retorna si el estado actual contiene un error.
  bool get hasError => _hasError;

  /// Actualiza el estado de carga global.
  ///
  /// Notifica a los listeners únicamente si el valor cambia,
  /// evitando reconstrucciones innecesarias.
  set isLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    safeNotify();
  }

  /// Actualiza el estado de error global.
  ///
  /// Notifica a los listeners únicamente si el valor cambia.
  set hasError(bool value) {
    if (_hasError == value) return;
    _hasError = value;
    safeNotify();
  }

  // ===============================================================
  // MENSAJES DE UI (ONE-SHOT)
  // ===============================================================

  /// Mensaje efímero destinado a la capa de presentación.
  ///
  /// Se utiliza para comunicar eventos puntuales como:
  /// - Mostrar un SnackBar
  /// - Mostrar un Toast
  /// - Informar el resultado de una acción
  ///
  /// Este mensaje **no forma parte del estado persistente**.
  UiMessage? _uiMessage;

  /// Retorna el mensaje de UI actual, si existe.
  UiMessage? get uiMessage => _uiMessage;

  /// Emite un nuevo mensaje de UI de tipo one-shot.
  ///
  /// Este método:
  /// - Es seguro frente a `dispose`
  /// - Debe usarse solo para eventos efímeros
  ///
  /// [text] Contenido del mensaje.
  /// [success] Indica si el mensaje representa una operación exitosa o fallida.
  void emitMessage(String text, {required bool success}) {
    runIfAlive(() {
      _uiMessage = UiMessage(text: text, success: success);
      notifyListeners();
    });
  }

  /// Limpia el mensaje de UI actual.
  ///
  /// Debe ser llamado por la capa de presentación una vez que
  /// el mensaje haya sido consumido, garantizando el comportamiento one-shot.
  void clearUiMessage() {
    _uiMessage = null;
  }

  // ===============================================================
  // RESET DE ESTADO
  // ===============================================================

  /// Restablece el estado base del ViewModel.
  ///
  /// Este método:
  /// - Limpia los estados globales
  /// - Elimina cualquier mensaje de UI pendiente
  ///
  /// Debe ser invocado al:
  /// - Reiniciar una pantalla
  /// - Cambiar de contexto
  /// - Reutilizar el ViewModel
  ///
  /// Las clases hijas **deben llamar a `super.resetState()`**
  /// si sobrescriben este método.
  @mustCallSuper
  void resetState() {
    _isLoading = false;
    _hasError = false;
    _uiMessage = null;
    safeNotify();
  }
}
