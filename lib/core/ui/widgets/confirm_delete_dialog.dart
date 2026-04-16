import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ===============================================================
/// ConfirmDeleteDialog
/// ---------------------------------------------------------------
/// Diálogo genérico de confirmación para operaciones destructivas
/// (eliminación).
///
/// CARACTERÍSTICAS:
/// - No depende de ningún ViewModel concreto.
/// - Reacciona a un estado externo de carga mediante [ValueListenable].
/// - Bloquea acciones mientras la operación está en progreso.
/// - Cierra el diálogo únicamente cuando la operación asíncrona finaliza.
///
/// Este enfoque permite reutilizar el diálogo en cualquier parte
/// de la aplicación sin acoplarlo a Provider, ChangeNotifier u otra
/// solución de estado.
/// ===============================================================
class ConfirmDeleteDialog extends StatelessWidget {
  /// Nombre del elemento que se va a eliminar.
  /// Se utiliza únicamente para mostrar feedback contextual al usuario.
  final String itemName;

  /// Callback asíncrono que ejecuta la lógica de eliminación.
  ///
  /// El diálogo no conoce la implementación interna:
  /// - Puede ser una llamada a un ViewModel
  /// - Un servicio
  /// - Un caso de uso
  ///
  /// Esto mantiene el widget desacoplado de la capa de dominio.
  final Future<void> Function() onConfirm;

  /// Estado reactivo que indica si la operación de eliminación
  /// se encuentra en progreso.
  ///
  /// Se recibe desde el exterior para evitar:
  /// - Acceder directamente a un ViewModel
  /// - Romper el principio de responsabilidad única
  ///
  /// Cuando es `true`, el diálogo:
  /// - Deshabilita los botones
  /// - Muestra un indicador de carga en el botón "Eliminar"
  final ValueListenable<bool> isLoading;

  const ConfirmDeleteDialog({
    super.key,
    required this.itemName,
    required this.onConfirm,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    /// ValueListenableBuilder permite reconstruir únicamente
    /// este diálogo cuando cambia el estado de carga.
    ///
    /// Evita el uso de setState y mantiene el widget inmutable.
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (_, loading, _) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Iconografía de advertencia para reforzar
              /// el carácter destructivo de la acción.
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),

              /// Título principal del diálogo.
              const Text(
                '¿Eliminar elemento?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /// Texto descriptivo con énfasis únicamente
              /// en el nombre del elemento a eliminar.
              ///
              /// RichText se usa para mantener una jerarquía visual clara
              /// sin dividir el texto en múltiples widgets.
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: '¿Estás seguro de eliminar '),
                    TextSpan(
                      text: '"$itemName"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              /// Advertencia adicional para evitar eliminaciones accidentales.
              Text(
                'Esta acción no se puede deshacer. '
                'Se eliminará permanentemente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[800]),
              ),
            ],
          ),

          /// ----------------------------------------------------------
          /// ACCIONES
          /// ----------------------------------------------------------
          actions: [
            /// Botón de cancelación.
            ///
            /// Se deshabilita durante la operación para:
            /// - Evitar cierres inconsistentes
            /// - Garantizar una UX predecible
            OutlinedButton(
              onPressed: loading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Cancelar'),
            ),

            /// Botón de confirmación.
            ///
            /// - Ejecuta la operación asíncrona.
            /// - Muestra un spinner mientras está en progreso.
            /// - Se deshabilita para evitar múltiples ejecuciones.
            ElevatedButton(
              onPressed: loading ? null : onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
