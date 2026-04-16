import 'package:flutter/foundation.dart';
import 'package:mi_semana/core/state/dispose_safe_notifier.dart';

/// Mixin encargado de gestionar estados de acciones puntuales de la UI.
///
/// Su objetivo es representar **operaciones específicas y temporales**
/// que no forman parte del estado global de carga, como:
/// - Guardar información
/// - Eliminar registros
///
/// Estos estados permiten a la capa de presentación:
/// - Deshabilitar botones concretos
/// - Mostrar loaders locales
/// - Evitar acciones duplicadas mientras una operación está en curso
///
/// ## Características
/// - Está pensado para usarse junto a ViewModels que extienden
///   [SafeChangeNotifier].
/// - Todos los cambios de estado son **dispose-safe**.
/// - No gestiona errores ni mensajes de UI.
/// - No representa estado persistente del dominio.
///
/// ## Diferencia con `isLoading`
/// - `isLoading`: estado global de la pantalla
/// - `isSaving` / `isDeleting`: acciones concretas y acotadas
mixin ActionStateManager on SafeChangeNotifier {
  // ===============================================================
  // ESTADO INTERNO
  // ===============================================================

  /// Indica si una operación de guardado está actualmente en curso.
  bool _isSaving = false;

  /// Indica si una operación de eliminación está actualmente en curso.
  bool _isDeleting = false;

  // ===============================================================
  // GETTERS
  // ===============================================================

  /// Retorna `true` si se está ejecutando una acción de guardado.
  bool get isSaving => _isSaving;

  /// Retorna `true` si se está ejecutando una acción de eliminación.
  bool get isDeleting => _isDeleting;

  // ===============================================================
  // MANEJO DE ESTADO
  // ===============================================================

  /// Actualiza el estado de guardado.
  ///
  /// Notifica a los listeners solo si el valor cambia,
  /// evitando reconstrucciones innecesarias.
  void setSaving(bool value) {
    if (_isSaving == value) return;
    _isSaving = value;
    safeNotify();
  }

  /// Actualiza el estado de eliminación.
  ///
  /// Notifica a los listeners solo si el valor cambia.
  void setDeleting(bool value) {
    if (_isDeleting == value) return;
    _isDeleting = value;
    safeNotify();
  }

  // ===============================================================
  // MÉTODO PROTEGIDO
  // ===============================================================

  /// Restablece todos los estados de acción a su valor inicial.
  ///
  /// Este método es **protegido** porque:
  /// - No debe ser invocado directamente desde la UI.
  /// - Cada operación debería limpiar su propio estado en bloques `finally`.
  ///
  /// Su uso está reservado para escenarios excepcionales, como:
  /// - Reinicialización completa del ViewModel
  /// - Limpieza forzada ante flujos inesperados
  @protected
  void resetActions() {
    _isSaving = false;
    _isDeleting = false;
    safeNotify();
  }
}
