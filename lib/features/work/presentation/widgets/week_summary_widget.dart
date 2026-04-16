import 'package:flutter/material.dart';
import 'package:mi_semana/features/work/domain/entities/constants/months_constants.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';
import 'package:mi_semana/features/work/domain/usecases/marcar_semana_como_pagada.dart';
import 'package:mi_semana/features/work/domain/usecases/obtener_detalle_semanal.dart';
import 'package:mi_semana/features/work/domain/usecases/verificar_semana_pagada.dart';
import 'package:mi_semana/features/work/presentation/constants/calendar_ui_constants.dart';
import 'package:mi_semana/features/work/presentation/model/week_visual_model.dart';
import 'package:mi_semana/features/work/presentation/screens/weekly_detail_screen.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/weekly_detail_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/weekly_summary_viewmodel.dart';
import 'package:provider/provider.dart';

class WeekSummaryWidget extends StatelessWidget {
  final List<WeekVisualModel> weeks;
  final WeeklySummaryViewmodel viewModel;
  final VoidCallback onWeekUpdated;

  const WeekSummaryWidget({
    super.key,
    required this.weeks,
    required this.viewModel,
    required this.onWeekUpdated,
  });

  String _formatearMoneda(double cantidad) {
    return 'S/ ${cantidad.toStringAsFixed(2)}';
  }

  Widget _buildPaymentStatusChip(bool estaPagada) {
    final paymentColor = CalendarUiConstants.colorPorEstado(estaPagada);
    final text = estaPagada ? 'Pagada' : 'Pendiente';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          estaPagada ? Icons.payments_rounded : Icons.pending_actions_rounded,
          color: paymentColor,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w600, color: paymentColor),
        ),
      ],
    );
  }

  Future<void> _handleTap(BuildContext context, WeekVisualModel week) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (context) {
            final repo = context.read<TrabajoRepositorio>();
            return WeeklyDetailViewmodel(
              ObtenerDetalleSemanal(repo),
              MarcarSemanaComoPagada(repo),
              VerificarSemanaPagada(repo),
            );
          },
          child: WeeklyDetailScreen(
            startDate: week.start,
            endDate: week.end,
            weekNumber: week.weekNumber,
          ),
        ),
      ),
    );

    if (result == true) {
      onWeekUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanasConDatos = weeks.where((week) {
      return viewModel.resumenSemanas.any(
        (r) => r.weekNumber == week.weekNumber,
      );
    }).toList();

    final bool estaCargando = viewModel.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),

      // LayoutBuilder permite conocer el alto disponible y evitar overflow
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header fijo
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resumen Semanal:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido flexible que se adapta al espacio disponible
              Expanded(
                child: estaCargando
                    ? const Center(child: CircularProgressIndicator())

                    // Estado vacío con scroll seguro para evitar overflow
                    : semanasConDatos.isEmpty
                        ? SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Aún no hay semanas con actividades registradas este mes.',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          )

                        // Lista normal
                        : ListView.builder(
                            itemCount: semanasConDatos.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final week = semanasConDatos[index];
                              final resumenSemana =
                                  viewModel.resumenSemanas.firstWhere(
                                (r) => r.weekNumber == week.weekNumber,
                              );

                              final startDate = week.start;
                              final endDate = week.end;

                              final weekColor = week.color;
                              final paymentColor =
                                  CalendarUiConstants.colorPorEstado(
                                resumenSemana.estaPagada,
                              );

                              final resumenActividades =
                                  resumenSemana.resumenActividades;
                              final total = resumenSemana.total;

                              return Card(
                                elevation: 3,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    width: 2,
                                    color: weekColor,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _handleTap(context, week),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: weekColor,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 15),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Sem ${week.weekNumber}: '
                                                      '(${startDate.day} ${MonthsConstants.getMonthAbbreviation(startDate.month)} - '
                                                      '${endDate.day} ${MonthsConstants.getMonthAbbreviation(endDate.month)})',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  _buildPaymentStatusChip(
                                                    resumenSemana.estaPagada,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      resumenActividades
                                                              .isNotEmpty
                                                          ? resumenActividades
                                                          : 'Sin resumen de actividades',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontStyle:
                                                            resumenActividades
                                                                    .isEmpty
                                                                ? FontStyle
                                                                    .italic
                                                                : FontStyle
                                                                    .normal,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Text(
                                                    _formatearMoneda(total),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 16,
                                                      color: paymentColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: weekColor,
                                          size: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}