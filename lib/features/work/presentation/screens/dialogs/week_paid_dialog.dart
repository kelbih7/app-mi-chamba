import 'package:flutter/material.dart';

/// Muestra un diálogo indicando que la semana ya fue pagada.
Future<void> showWeekPaidDialog(BuildContext context) {
  // Definimos el color de énfasis para este diálogo de restricción
  final Color restrictionColor = Theme.of(context).colorScheme.error;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      // Usamos AlertDialog para mayor simplicidad y conformidad al Material Design,
      // pero si queremos mantener la estructura original, la adaptamos:
      child: Container(
        // Reemplazamos Card por Container para un control más fino
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Un poco más de redondeo
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Icono y Título Centrales (Moderno y enfocado)
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                children: [
                  Icon(Icons.lock_outline, color: restrictionColor, size: 48),
                  const SizedBox(height: 15),
                  Text(
                    "Acceso Restringido",
                    style: TextStyle(
                      color: restrictionColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Semana Pagada",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                ],
              ),
            ),

            // 2. Mensaje Descriptivo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Esta semana ya está marcada como pagada. Por lo general, esto bloquea la posibilidad de modificar o añadir nuevos registros.",
                style: TextStyle(fontSize: 15, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 25),

            // 3. Botón de Acción
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    // El color del texto usa el tema, no un color fijo
                    child: Text(
                      "ENTENDIDO",
                      style: TextStyle(
                        color:
                            restrictionColor, // Usamos el color de restricción
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
