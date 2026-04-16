import 'package:mi_semana/core/services/exception_handler_of_db.dart';
import 'package:mi_semana/core/state/base_vm_state_manager.dart';
import 'package:mi_semana/core/utils/date_day_mapper.dart';
import 'package:mi_semana/core/utils/week_domain_helper.dart';
import 'package:mi_semana/features/work/domain/entities/estado_dia_calendario.dart';
import 'package:mi_semana/features/work/domain/usecases/obtener_estado_dias_mensual.dart';
import 'package:mi_semana/features/work/domain/usecases/verificar_semana_pagada.dart';

/// ViewModel responsable del estado del calendario mensual.
///
/// Funcionalidad principal:
/// - Orquestar la carga del estado lógico de todos los días de un mes.
/// - Aplicar reglas de dominio relacionadas con semanas pagadas.
/// - Exponer datos inmutables y listos para ser consumidos por la UI.
///
/// Este ViewModel no contiene lógica de presentación ni decisiones visuales.
class CalendarViewModel extends BaseVmStateManager with ExceptionHandlerOfDb {
  /// Caso de uso para obtener los días del mes que tienen registro.
  final ObtenerEstadoDiasMensual obtenerEstadoDiasMensual;

  /// Caso de uso para verificar si una semana (lunes) está pagada.
  final VerificarSemanaPagada verificarSemanaPagada;

  CalendarViewModel({
    required this.obtenerEstadoDiasMensual,
    required this.verificarSemanaPagada,
  });

  /// Estado interno con todos los días del mes.
  List<EstadoDiaCalendario> _estados = [];

  /// Mes actualmente cargado (normalizado a año/mes).
  DateTime _mesActivo = DateTime.now();

  /// Estados expuestos a la UI (solo lectura).
  List<EstadoDiaCalendario> get estados => _estados;

  /// Mes actualmente activo.
  DateTime get mesActivo => _mesActivo;

  /// Carga o recarga el estado del calendario para un mes específico.
  ///
  /// - Normaliza el mes recibido (ignora día).
  /// - Evita recargas innecesarias si el mes ya está cargado.
  /// - Aplica reglas de bloqueo semanal según semanas pagadas.
  Future<void> cargarMes(DateTime mes, {bool forceRefresh = false}) async {
    final nuevoMes = DateTime(mes.year, mes.month);

    // Evita recargar si el mes ya está cargado y no se fuerza refresco.
    if (!forceRefresh &&
        _mesActivo.year == nuevoMes.year &&
        _mesActivo.month == nuevoMes.month &&
        _estados.isNotEmpty) {
      return;
    }

    _mesActivo = nuevoMes;
    isLoading = true;

    try {
      // 1. Obtener desde dominio los días del mes que tienen registro.
      final diasConRegistro = await obtenerEstadoDiasMensual(_mesActivo);

      // 2. Determinar qué semanas están pagadas.
      //    Solo se consultan semanas que realmente tienen registros.
      final Map<DateTime, bool> semanasPagadas = {};

      if (diasConRegistro.isNotEmpty) {
        final semanas = <DateTime>{};

        for (final d in diasConRegistro) {
          semanas.add(
            WeekDomainHelper.startOfWeek(DateDayMapper.toLocalDay(d.fecha)),
          );
        }

        for (final lunes in semanas) {
          final pagada = await verificarSemanaPagada(lunes);
          semanasPagadas[lunes] = pagada;
        }
      }

      // 3. Construir un mapa rápido de días que tienen registro.
      final Map<DateTime, EstadoDiaCalendario> mapaDias = {
        for (final e in diasConRegistro)
          DateDayMapper.toLocalDay(e.fecha): EstadoDiaCalendario(
            fecha: DateDayMapper.toLocalDay(e.fecha),
            tieneRegistro: true,
            estaPagado: e.estaPagado,
            semanaBloqueada: false,
          ),
      };

      // 4. Construir todos los días del mes (contrato completo para la UI).
      final primerDia = DateTime(_mesActivo.year, _mesActivo.month, 1);
      final ultimoDia = DateTime(_mesActivo.year, _mesActivo.month + 1, 0);

      _estados = [];

      for (int i = 0; i < ultimoDia.day; i++) {
        final fecha = DateTime(primerDia.year, primerDia.month, i + 1);

        final localFecha = DateDayMapper.toLocalDay(fecha);
        final lunes = WeekDomainHelper.startOfWeek(localFecha);

        // Estado base del día: con registro o vacío.
        final estadoBase =
            mapaDias[localFecha] ??
            EstadoDiaCalendario(
              fecha: localFecha,
              tieneRegistro: false,
              estaPagado: false,
              semanaBloqueada: false,
            );

        // Regla de dominio:
        // Si la semana está pagada, todos los días de esa semana
        // quedan bloqueados.
        final bloqueada = semanasPagadas[lunes] ?? false;

        _estados.add(estadoBase.copyWith(semanaBloqueada: bloqueada));
      }
    } catch (e) {
      // En caso de error se limpia el estado y se delega el manejo.
      _estados = [];

      handleException(
        e,
        fallback: 'Error cargando calendario mensual',
        operation: 'cargar mes calendario',
      );
    } finally {
      isLoading = false;
    }
  }

  // -----------------------------------------------------------------
  // CONSULTAS PARA LA UI
  // -----------------------------------------------------------------

  /// Indica si un día específico tiene al menos un registro.
  bool tieneRegistro(DateTime day) {
    final localDay = DateDayMapper.toLocalDay(day);

    return _estados.any((e) => _mismoDia(e.fecha, localDay) && e.tieneRegistro);
  }

  /// Retorna el estado completo de un día específico.
  ///
  /// Siempre retorna un objeto válido, incluso si el día no existe
  /// en el estado actual.
  EstadoDiaCalendario estadoDe(DateTime day) {
    final localDay = DateDayMapper.toLocalDay(day);

    return _estados.firstWhere(
      (e) => _mismoDia(e.fecha, localDay),
      orElse: () => EstadoDiaCalendario(
        fecha: localDay,
        tieneRegistro: false,
        estaPagado: false,
        semanaBloqueada: false,
      ),
    );
  }

  /// Limpia el estado interno del ViewModel.
  ///
  /// Útil cuando se destruye la vista o se reinicia el flujo.
  void limpiar() {
    _estados = [];
    resetState();
  }

  // -----------------------------------------------------------------
  // HELPERS INTERNOS
  // -----------------------------------------------------------------

  /// Compara dos fechas ignorando hora y zona.
  bool _mismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
