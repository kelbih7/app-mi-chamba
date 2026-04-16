import 'package:flutter/material.dart';

/// Diálogo de confirmación genérico para cambiar el estado de pago de una semana.
/// Retorna `true` si el usuario confirma la acción, `false` si cancela, o `null` si se cierra.
class WeeklyPaymentConfirmationDialog extends StatelessWidget {
  final int weekNumber;
  final double total;
  final bool nuevoEstado; // true = pagada
  final String Function(double) formatearMoneda;

  const WeeklyPaymentConfirmationDialog({
    super.key,
    required this.weekNumber,
    required this.total,
    required this.nuevoEstado,
    required this.formatearMoneda,
  });

  @override
  Widget build(BuildContext context) {
    // Definiciones de texto y color basadas en el nuevo estado
    final String titulo = nuevoEstado
        ? 'Confirmar Pago'
        : 'Marcar como Pendiente';
    final String mensaje = nuevoEstado
        ? '¿Estás seguro de marcar la Semana $weekNumber como pagada?'
        : '¿Estás seguro de marcar la Semana $weekNumber como pendiente?';
    final String textoBotonConfirmar = nuevoEstado
        ? 'Confirmar'
        : 'Confirmar';

    final Color colorPrincipal = nuevoEstado ? Colors.green : Colors.orange;
    final IconData icono = nuevoEstado
        ? Icons.check_circle_outline
        : Icons.pending_actions;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono según la acción (Pagado o Pendiente)
            Center(child: Icon(icono, color: colorPrincipal, size: 60.0)),
            const SizedBox(height: 16.0),

            // Título
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            // Mensaje de confirmación
            Text(mensaje, style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 10.0),

            // Total destacado
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color: colorPrincipal.withAlpha(30),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Total: ${formatearMoneda(total)}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: colorPrincipal,
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón Cancelar (retorna false)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Botón Confirmar (retorna true)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrincipal,
                  ),
                  child: Text(
                    textoBotonConfirmar,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
