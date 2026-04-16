import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_semana/core/utils/calendar_week_mapper.dart';
import 'package:mi_semana/features/work/domain/entities/estado_dia_calendario.dart';
import 'package:mi_semana/features/work/presentation/constants/calendar_ui_constants.dart';
import 'package:mi_semana/features/work/presentation/model/week_visual_model.dart';
import 'package:mi_semana/features/work/presentation/screens/daily_work_registration_screen.dart';
import 'package:mi_semana/features/work/presentation/screens/dialogs/week_paid_dialog.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/catalog_work_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/daily_work_registration_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/weekly_summary_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/widgets/bottom_app_bar_widget.dart';
import 'package:mi_semana/features/work/presentation/widgets/empty_catalog_state.dart';
import 'package:mi_semana/features/work/presentation/widgets/week_summary_widget.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? openDay;
  const CalendarScreen({super.key, this.openDay});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<WeekVisualModel> _weeks = [];

  @override
  void initState() {
    super.initState();

    final initialDay = _normalizeDay(widget.openDay ?? _today);

    _focusedDay = initialDay;
    _selectedDay = initialDay;
    _weeks = CalendarWeekMapper.buildWeeks(initialDay);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _recargarMes(initialDay);

      if (widget.openDay != null && mounted) {
        if (_canOpenDay(initialDay)) {
          await _abrirRegistroParaDia(initialDay);
        }
      }
    });
  }

  DateTime _normalizeDay(DateTime d) => DateTime(d.year, d.month, d.day);

  (DateTime, DateTime) _rangoMes(DateTime day) {
    final inicio = DateTime(day.year, day.month, 1);
    final fin = DateTime(day.year, day.month + 1, 0);
    return (inicio, fin);
  }

  Future<void> _recargarMes(DateTime day, {bool force = false}) async {
    final normalized = _normalizeDay(day);

    final (inicioMes, _) = _rangoMes(normalized);

    final weeks = CalendarWeekMapper.buildWeeks(normalized);
    final inicioSemanas = weeks.first.start;
    final finSemanas = weeks.last.end;

    await Future.wait([
      context.read<CalendarViewModel>().cargarMes(
        inicioMes,
        forceRefresh: force,
      ),
      context.read<WeeklySummaryViewmodel>().cargarResumen(
        inicioSemanas,
        finSemanas,
      ),
    ]);
  }

  void _onPageChanged(DateTime focusedDay) {
    final normalized = _normalizeDay(focusedDay);

    setState(() {
      _focusedDay = normalized;
      _weeks = CalendarWeekMapper.buildWeeks(normalized);
    });

    _recargarMes(normalized);
  }

  Widget _buildCalendar(CalendarViewModel vm, bool isSmallScreen) {
    return TableCalendar(
      locale: 'es_ES',
      focusedDay: _focusedDay,
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2045, 12, 31),
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: isSmallScreen ? 36 : 48, // controla altura del calendario
      daysOfWeekHeight: isSmallScreen ? 18 : 28,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        final normalized = _normalizeDay(selectedDay);

        final esDelMes =
            normalized.month == _focusedDay.month &&
            normalized.year == _focusedDay.year;

        if (!esDelMes) {
          setState(() {
            _focusedDay = normalized;
            _selectedDay = null;
          });
          return;
        }

        if (!_canOpenDay(normalized)) return;

        setState(() {
          _selectedDay = normalized;
          _focusedDay = normalized;
        });

        _abrirRegistroParaDia(normalized);
      },
      onPageChanged: _onPageChanged,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: isSmallScreen ? 14 : 18,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: isSmallScreen ? 22 : 30,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.white,
          size: isSmallScreen ? 22 : 30,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) => _buildDayCell(
          context,
          day,
          vm.estadoDe(day),
          isToday: false,
          isSelected: false,
          isSmall: isSmallScreen,
        ),
        todayBuilder: (context, day, _) => _buildDayCell(
          context,
          day,
          vm.estadoDe(day),
          isToday: true,
          isSelected: isSameDay(day, _selectedDay),
          isSmall: isSmallScreen,
        ),
        selectedBuilder: (context, day, _) => _buildDayCell(
          context,
          day,
          vm.estadoDe(day),
          isToday: isSameDay(day, _today),
          isSelected: true,
          isSmall: isSmallScreen,
        ),
        dowBuilder: (context, day) {
          final text = DateFormat.E('es_ES').format(day);
          return Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    EstadoDiaCalendario? estado, {
    required bool isToday,
    required bool isSelected,
    required bool isSmall,
  }) {
    final isBlocked = estado?.semanaBloqueada == true;

    final bgColor = isSelected
        ? CalendarUiConstants.selectedDayColor
        : (isToday ? CalendarUiConstants.todayColor : Colors.transparent);

    final indicatorColor = (estado != null && estado.tieneRegistro)
        ? CalendarUiConstants.colorPorEstado(estado.estaPagado)
        : null;

    final weekColor = CalendarWeekMapper.colorForDay(day, _weeks);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: weekColor != null
                ? Border.all(color: weekColor.withAlpha(200), width: isSmall ? 1 : 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 11 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (isBlocked)
          const Positioned(
            top: 4,
            right: 4,
            child: Icon(Icons.lock, size: 10, color: Colors.white70),
          ),
        if (indicatorColor != null)
          Positioned(
            bottom: 4,
            child: Container(
              width: isSmall ? 5 : 8,
              height: isSmall ? 5 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: indicatorColor,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Detecta pantallas pequeñas
    final isSmallScreen = size.height < 700 || size.width < 360;

    final catalogVM = context.watch<CatalogWorkViewmodel>();

    if (catalogVM.trabajos.isEmpty) {
      return const EmptyCatalogState();
    }

    final calendarVM = context.watch<CalendarViewModel>();
    final summaryVM = context.watch<WeeklySummaryViewmodel>();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_icon.png',
              height: isSmallScreen ? 28 : 40,
            ),
            const SizedBox(width: 8),
            Text(
              'Mi Chamba',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: isSmallScreen ? 18 : 24,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 4 : 8,
                horizontal: isSmallScreen ? 6 : 12,
              ),
              child: _buildCalendar(calendarVM, isSmallScreen),
            ),

            // El resumen ocupa el resto sin romper layout
            Expanded(
              child: WeekSummaryWidget(
                weeks: _weeks,
                viewModel: summaryVM,
                onWeekUpdated: () {
                  _recargarMes(_focusedDay, force: true);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final today = _normalizeDay(_today);
          if (!_canOpenDay(today)) return;

          setState(() {
            _selectedDay = today;
            _focusedDay = today;
            _weeks = CalendarWeekMapper.buildWeeks(today);
          });

          await _abrirRegistroParaDia(today);
        },
        child: Icon(
          Icons.add,
          size: isSmallScreen ? 24 : 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBarWidget(),
    );
  }

  Future<void> _abrirRegistroParaDia(DateTime selectedDay) async {
    final day = _normalizeDay(selectedDay);
    final dailyVM = context.read<DailyWorkRegistrationViewmodel>();

    await dailyVM.inicializarParaFecha(day);

    if (!mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DailyWorkRegistrationScreen(selectedDay: day),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _selectedDay = day;
        _focusedDay = day;
      });
      _recargarMes(day, force: true);
    }
  }

  bool _canOpenDay(DateTime day) {
    final calendarVM = context.read<CalendarViewModel>();
    final estado = calendarVM.estadoDe(day);

    if (estado.semanaBloqueada == true) {
      showWeekPaidDialog(context);
      return false;
    }
    return true;
  }
}