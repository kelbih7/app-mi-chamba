import 'package:flutter/material.dart';

/// Widget que muestra una capa bloqueante encima del contenido
/// cuando [isBlocking] es true.
///
/// Útil para operaciones críticas como:
/// - guardar
/// - eliminar
/// - sincronizar
///
/// Bloquea interacción y muestra un indicador de carga.
class BlockingLoadingOverlay extends StatelessWidget {
  final bool isBlocking;
  final Widget child;

  const BlockingLoadingOverlay({
    super.key,
    required this.isBlocking,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isBlocking) return child;

    return Stack(
      children: [
        child,
        AbsorbPointer(
          absorbing: true,
          child: Container(
            color: Colors.black.withAlpha(150),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ],
    );
  }
}
