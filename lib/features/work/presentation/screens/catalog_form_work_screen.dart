import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_semana/core/utils/validate_inputs.dart';
import 'package:mi_semana/features/work/domain/entities/constants/work_constants.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/trabajo_catalogo.dart';
import '../viewmodels/catalog_work_viewmodel.dart';

class CatalogFormWorkScreen extends StatefulWidget {
  final Trabajo? trabajo;
  const CatalogFormWorkScreen({super.key, this.trabajo});

  @override
  State<CatalogFormWorkScreen> createState() => _CatalogFormWorkScreenState();
}

class _CatalogFormWorkScreenState extends State<CatalogFormWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreController;
  late TextEditingController pagoController;
  late int colorId;
  late int iconoId;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(
      text: widget.trabajo?.nombre ?? '',
    );
    pagoController = TextEditingController(
      text: widget.trabajo?.pagoPredeterminado.toString() ?? '',
    );
    colorId = widget.trabajo?.color ?? 1;
    iconoId = widget.trabajo?.icono ?? 1;
  }

  @override
  void dispose() {
    nombreController.dispose();
    pagoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final viewModel = context.read<CatalogWorkViewmodel>();

    final nombre = nombreController.text.trim();
    final pago = double.tryParse(pagoController.text.trim()) ?? 0;

    final trabajoAOperar = Trabajo(
      id: widget.trabajo?.id,
      nombre: nombre,
      pagoPredeterminado: pago,
      color: colorId,
      icono: iconoId,
    );

    //showLoadingDialog();

    try {
      final bool success = widget.trabajo == null
          ? await viewModel.agregarTrabajo(trabajoAOperar)
          : await viewModel.actualizarTrabajo(trabajoAOperar);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      }
    } finally {
      //hideLoadingDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.trabajo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEdicion ? "Editar Trabajo" : "Agregar Trabajo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del trabajo',
                      ),
                      validator: (value) => ValidateInputs.validateIsEmpty(
                        value,
                        'Nombre del trabajo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: pagoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Pago predeterminado',
                      ),
                      validator: (value) {
                        final error = ValidateInputs.validateIsEmpty(
                          value,
                          'Pago predeterminado',
                        );
                        if (error != null) return error;
                        final parsed = double.tryParse(value!);
                        if (parsed == null || parsed <= 0) {
                          return 'El pago debe ser un número mayor a 0.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Selecciona un color:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: WorkConstants.coloresMap.entries.map((e) {
                        final color = e.value['color'] as Color;
                        final isSelected = colorId == e.key;
                        return ChoiceChip(
                          label: Text(
                            e.value['nombre'] as String,
                            style: const TextStyle(color: Colors.white),
                          ),
                          selectedColor: color,
                          backgroundColor: color.withAlpha(200),
                          selected: isSelected,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                          onSelected: (_) => setState(() => colorId = e.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Selecciona un icono:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: WorkConstants.iconosMap.entries.map((e) {
                        final icono = e.value['icono'] as IconData;
                        final isSelected = iconoId == e.key;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icono, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                e.value['nombre'] as String,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          selectedColor: Colors.green,
                          backgroundColor: Colors.grey.shade800,
                          selected: isSelected,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                          onSelected: (_) => setState(() => iconoId = e.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        child: Text(
                          esEdicion ? "ACTUALIZAR" : "AGREGAR",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
