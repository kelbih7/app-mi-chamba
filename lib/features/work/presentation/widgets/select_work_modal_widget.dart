import 'package:flutter/material.dart';
import 'package:mi_semana/features/work/domain/entities/constants/work_constants.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_catalogo.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/catalog_work_viewmodel.dart';
import 'package:provider/provider.dart';

class SelectWorkModalWidget extends StatelessWidget {
  final void Function(Trabajo trabajo) onWorkSelected;

  const SelectWorkModalWidget({super.key, required this.onWorkSelected});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatalogWorkViewmodel>();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
            top: BorderSide(color: Colors.grey.withAlpha(150), width: 1.0),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const Text(
              'Seleccionar un trabajo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (viewModel.trabajos.isEmpty)
              const Center(child: Text('No hay trabajos disponibles'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.trabajos.length,
                  itemBuilder: (_, index) {
                    final trabajo = viewModel.trabajos[index];
                    final color =
                        WorkConstants.coloresMap[trabajo.color]?['color']
                            as Color? ??
                        Colors.grey;
                    final icon =
                        WorkConstants.iconosMap[trabajo.icono]?['icono']
                            as IconData? ??
                        Icons.work;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withAlpha(50),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(trabajo.nombre),
                        trailing: Text(
                          'S/. ${trabajo.pagoPredeterminado.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          onWorkSelected(trabajo);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
