import 'package:flutter/foundation.dart';

/// ChangeNotifier con protección contra notificaciones
/// luego de haber sido disposed.
///
/// Centraliza la lógica de lifecycle safety para
/// evitar errores del tipo:
/// "setState() or markNeedsBuild() called after dispose()".
///
/// Debe ser la base de todos los ViewModels que
/// ejecuten operaciones asíncronas.
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;

  /// Indica si el notifier sigue vivo.
  bool get isAlive => !_isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Ejecuta una acción solo si el notifier
  /// no ha sido disposed.
  ///
  /// Usar este método para envolver:
  /// - notifyListeners
  /// - emisiones de mensajes UI
  /// - cambios de estado post-async
  @protected
  void runIfAlive(VoidCallback action) {
    if (!_isDisposed) {
      action();
    }
  }

  /// Notifica listeners solo si el notifier
  /// sigue vivo.
  ///
  /// Conveniencia para los casos más comunes.
  @protected
  void safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
