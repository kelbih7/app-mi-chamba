import 'package:flutter/material.dart';
import 'package:mi_semana/core/ui/toast/app_toast.dart';
import 'package:mi_semana/core/ui/widgets/blocking_loading_overlay.dart';
import 'package:mi_semana/features/work/domain/entities/constants/months_constants.dart';
import 'package:mi_semana/features/work/domain/entities/constants/work_constants.dart';
import 'package:mi_semana/features/work/domain/entities/detalle_semana.dart';
import 'package:mi_semana/features/work/presentation/constants/calendar_ui_constants.dart';
import 'package:mi_semana/features/work/presentation/screens/dialogs/weekly_payment_confirmation_dialog.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/weekly_detail_viewmodel.dart';
import 'package:provider/provider.dart';

// =========================================================================
// WEEKLY DETAIL SCREEN
// =========================================================================

class WeeklyDetailScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int weekNumber;

  const WeeklyDetailScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.weekNumber,
  });

  @override
  State<WeeklyDetailScreen> createState() => _WeeklyDetailScreenState();
}

class _WeeklyDetailScreenState extends State<WeeklyDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeeklyDetailViewmodel>().cargarSemana(
        widget.startDate,
        widget.endDate,
        widget.weekNumber,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dailyVM = context.watch<WeeklyDetailViewmodel>();
    final uiMessage = dailyVM.uiMessage;

    if (uiMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        AppToast.show(
          context,
          message: uiMessage.text,
          isSuccess: uiMessage.success,
        );

        dailyVM.clearUiMessage();
      });
    }
  }

  // =========================================================================
  // HELPERS (UI PURO)
  // =========================================================================

  Color _obtenerColorTrabajo(int colorId) {
    final map = WorkConstants.coloresMap[colorId];
    return map != null ? map['color'] as Color : Colors.grey;
  }

  IconData _obtenerIconoTrabajo(int iconoId) {
    final map = WorkConstants.iconosMap[iconoId];
    return map != null ? map['icono'] as IconData : Icons.help_outline;
  }

  String _formatearMoneda(double monto) {
    return 'S/ ${monto.toStringAsFixed(2)}';
  }

  String _formatearRangoSemanas(DateTime start, DateTime end) {
    final startDay = start.day;
    final endDay = end.day;

    final startMonth = MonthsConstants.getMonthAbbreviation(start.month);
    final endMonth = MonthsConstants.getMonthAbbreviation(end.month);

    if (start.month == end.month) {
      return '$startDay al $endDay de $startMonth';
    }

    return '$startDay $startMonth al $endDay $endMonth';
  }

  String _formatearMesesRango(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${MonthsConstants.getMonthFullName(start.month)} ${start.year}';
    }

    final startMonth = MonthsConstants.getMonthAbbreviation(start.month);
    final endMonth = MonthsConstants.getMonthFullName(end.month);

    return '$startMonth - $endMonth ${end.year}';
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeeklyDetailViewmodel>();

    if (vm.isLoading || vm.semana == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final semana = vm.semana!;

    final totalSemana = semana.dias.fold<double>(
      0,
      (sum, dia) => sum + dia.total,
    );

    /// loading crítico (guardar / eliminar)
    final isBlocking = vm.isSaving;
    return BlockingLoadingOverlay(
      isBlocking: isBlocking,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: Text('Resumen de semana ${semana.weekNumber}')),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            _buildHeader(context, semana, totalSemana),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withAlpha(245),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 25,
                  ),
                  itemCount: semana.dias.length,
                  itemBuilder: (_, index) {
                    final dia = semana.dias[index];

                    return _DiaDetailCard(
                      dia: dia,
                      formatearMoneda: _formatearMoneda,
                      obtenerColorTrabajo: _obtenerColorTrabajo,
                      obtenerIconoTrabajo: _obtenerIconoTrabajo,
                    );
                  },
                ),
              ),
            ),
            _buildFooter(context, semana, totalSemana),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HEADER & FOOTER
  // =========================================================================

  Widget _buildHeader(
    BuildContext context,
    DetalleSemana semana,
    double totalSemana,
  ) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periodo: ${_formatearRangoSemanas(widget.startDate, widget.endDate)}',
            style: TextStyle(color: Colors.white.withAlpha(180)),
          ),
          const SizedBox(height: 4),
          Text(
            _formatearMesesRango(widget.startDate, widget.endDate),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monto a Liquidar',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                _formatearMoneda(totalSemana),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: CalendarUiConstants.paidColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    DetalleSemana semana,
    double totalSemana,
  ) {
    final bool isPaid = semana.estaPagada;
    final Color statusColor = CalendarUiConstants.colorPorEstado(isPaid);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 2,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =========================
          // ESTADO DE PAGO (LABEL + BADGE)
          // =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ESTADO DE PAGO:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle : Icons.pending,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPaid ? 'PAGADA' : 'PENDIENTE',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =========================
          // BOTÓN DE ACCIÓN
          // =========================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final vm = context.read<WeeklyDetailViewmodel>();
                final navigator = Navigator.of(context);

                final bool nuevoEstado = !isPaid;

                final confirmacion = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => WeeklyPaymentConfirmationDialog(
                    weekNumber: semana.weekNumber,
                    total: totalSemana,
                    nuevoEstado: nuevoEstado,
                    formatearMoneda: _formatearMoneda,
                  ),
                );

                if (!mounted || confirmacion != true) return;

                final ok = await vm.cambiarEstadoPagoSemana(nuevoEstado);
                if (!mounted || !ok) return;

                navigator.pop(true);
              },

              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(
                isPaid ? 'MARCAR COMO PENDIENTE' : 'MARCAR COMO PAGADA',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// DIA DETAIL CARD
// =========================================================================

class _DiaDetailCard extends StatelessWidget {
  final DetalleDia dia;
  final String Function(double) formatearMoneda;
  final Color Function(int) obtenerColorTrabajo;
  final IconData Function(int) obtenerIconoTrabajo;

  const _DiaDetailCard({
    required this.dia,
    required this.formatearMoneda,
    required this.obtenerColorTrabajo,
    required this.obtenerIconoTrabajo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [_buildHeader(), ...dia.actividades.map(_buildActividadRow)],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              MonthsConstants.formatFullDateWithDay(dia.fecha),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatearMoneda(dia.total),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadRow(DetalleActividad act) {
    final color = obtenerColorTrabajo(act.colorId);
    final icono = obtenerIconoTrabajo(act.iconoId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icono, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text('${act.nombre} (x${act.cantidad})'),
            ],
          ),
          Text(formatearMoneda(act.subtotal)),
        ],
      ),
    );
  }
}
