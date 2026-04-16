import 'package:flutter/material.dart';
import 'package:mi_semana/features/work/presentation/screens/catalog_work_screen.dart';

class EmptyCatalogState extends StatelessWidget {
  const EmptyCatalogState({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Semana")),
      body: SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 👈 CLAVE
                  children: [
                    // Icono principal
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: primary.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.work_outline,
                        size: 64,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Título
                    const Text(
                      "Aún no tienes trabajos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Explicación
                    const Text(
                      "Crea tu primer trabajo para comenzar a registrar "
                      "los días que trabajas en el calendario.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),

                    const SizedBox(height: 28),

                    // Paso visual
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Primero crearás un trabajo y luego podrás registrar "
                        "tus días directamente en el calendario.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botón principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Crear mi primer trabajo",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CatalogWorkScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ayuda secundaria
                    Text(
                      "Podrás editar o eliminar trabajos más adelante.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  ),
),);
  }
}
