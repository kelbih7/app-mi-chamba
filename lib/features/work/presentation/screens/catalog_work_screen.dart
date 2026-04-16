import 'package:flutter/material.dart';
import 'package:mi_semana/core/state/flag_listenable.dart';
import 'package:mi_semana/core/ui/toast/app_toast.dart';
import 'package:mi_semana/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_catalogo.dart';
import 'package:mi_semana/features/work/domain/entities/constants/work_constants.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/catalog_work_viewmodel.dart';
import 'package:provider/provider.dart';
import 'catalog_form_work_screen.dart';

class CatalogWorkScreen extends StatefulWidget {
  const CatalogWorkScreen({super.key});

  @override
  State<CatalogWorkScreen> createState() => _CatalogWorkScreenState();
}

class _CatalogWorkScreenState extends State<CatalogWorkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogWorkViewmodel>().cargarTrabajos();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final viewModel = context.watch<CatalogWorkViewmodel>();
    final uiMessage = viewModel.uiMessage;

    if (uiMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        AppToast.show(
          context,
          message: uiMessage.text,
          isSuccess: uiMessage.success,
        );

        viewModel.clearUiMessage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatalogWorkViewmodel>();
    //loading
    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    //body
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Trabajos'),
        centerTitle: true,
      ),
      body: _buildContent(viewModel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildContent(CatalogWorkViewmodel viewModel) {
    if (viewModel.trabajos.isEmpty) {
      return const Center(child: Text('No hay trabajos registrados.'));
    }

    return SafeArea(
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          80 + MediaQuery.of(context).viewPadding.bottom,
        ),
        itemCount: viewModel.trabajos.length,
        itemBuilder: (_, index) {
          final trabajo = viewModel.trabajos[index];

          final color =
              WorkConstants.coloresMap[trabajo.color]?['color'] as Color? ??
              Colors.grey;

          final icon =
              WorkConstants.iconosMap[trabajo.icono]?['icono'] as IconData? ??
              Icons.work;

          return _WorkItemCard(
            trabajo: trabajo,
            color: color,
            icon: icon,
            onEdit: () => _navigateToForm(context, trabajo: trabajo),
            onDelete: () => _confirmarEliminar(trabajo.id!, trabajo.nombre),
          );
        },
      ),
    );
  }

  void _confirmarEliminar(int id, String nombre) {
    final viewModel = context.read<CatalogWorkViewmodel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return FlagListenableBuilder(
          notifier: viewModel,
          selector: (vm) => vm.isDeleting,
          builder: (isDeleting) {
            return ConfirmDeleteDialog(
              itemName: nombre,
              isLoading: isDeleting,
              onConfirm: () async {
                await viewModel.eliminarTrabajo(id);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
            );
          },
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, {Trabajo? trabajo}) {
    final viewModel = context.read<CatalogWorkViewmodel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: CatalogFormWorkScreen(trabajo: trabajo),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// WORK ITEM CARD
/// ---------------------------------------------------------------------------

class _WorkItemCard extends StatelessWidget {
  final Trabajo trabajo;
  final Color color;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkItemCard({
    required this.trabajo,
    required this.color,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// -------------------------------
          /// Información principal
          /// -------------------------------
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(50),
                child: Icon(icon, color: color),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trabajo.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Pago predeterminado: "
                      "S/. ${trabajo.pagoPredeterminado.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// -------------------------------
          /// Acciones
          /// -------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Editar"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text("Eliminar"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
