import 'package:mi_semana/features/work/data/datasources/trabajo_local_data_source.dart';
import 'package:mi_semana/features/work/data/mappers/trabajo_dia_mapper.dart';
import 'package:mi_semana/features/work/data/mappers/trabajo_dia_model_mapper.dart';
import 'package:mi_semana/features/work/data/models/estado_dia_calendario_model.dart';
import 'package:mi_semana/features/work/data/models/semana_pagada_model.dart';
import 'package:mi_semana/features/work/data/models/trabajo_catalog_model.dart';
import 'package:mi_semana/features/work/domain/entities/estado_dia_calendario.dart';
import 'package:mi_semana/features/work/domain/entities/semana_pagada.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_catalogo.dart';
import 'package:mi_semana/features/work/domain/entities/trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

/// Implementación concreta del repositorio de trabajos.
///
/// - Convierte MODELOS (data layer) en ENTIDADES (domain layer)
/// - Centraliza toda la lógica de acceso a datos
/// - Aísla al dominio de detalles de base de datos
class TrabajoRepositorioImpl implements TrabajoRepositorio {
  final TrabajoLocalDataSource dataSource;

  TrabajoRepositorioImpl(this.dataSource);

  // ============================================================
  // ========== TRABAJOS (ENTIDAD PRINCIPAL) ====================
  // ============================================================

  /// Obtiene todos los trabajos registrados
  @override
  Future<List<Trabajo>> obtenerTrabajos() async {
    final modelos = await dataSource.getTrabajos();

    return modelos.map((m) {
      return Trabajo(
        id: m.id,
        nombre: m.nombre,
        pagoPredeterminado: m.pagoPredeterminado,
        color: m.color,
        icono: m.icono,
      );
    }).toList();
  }

  /// Inserta un nuevo trabajo
  @override
  Future<Trabajo> agregarTrabajo(Trabajo trabajo) async {
    final model = TrabajoCatalogoModel(
      id: trabajo.id,
      nombre: trabajo.nombre,
      pagoPredeterminado: trabajo.pagoPredeterminado,
      color: trabajo.color,
      icono: trabajo.icono,
    );

    // El datasource devuelve el ID generado
    final id = await dataSource.insertarTrabajo(model);

    // Se retorna la ENTIDAD, no el modelo
    return trabajo.copyWith(id: id);
  }

  /// Actualiza un trabajo existente
  @override
  Future<Trabajo> actualizarTrabajo(Trabajo trabajo) async {
    final model = TrabajoCatalogoModel(
      id: trabajo.id,
      nombre: trabajo.nombre,
      pagoPredeterminado: trabajo.pagoPredeterminado,
      color: trabajo.color,
      icono: trabajo.icono,
    );

    await dataSource.actualizarTrabajo(model);
    return trabajo;
  }

  /// Elimina un trabajo por ID
  @override
  Future<int> eliminarTrabajo(int id) async {
    return await dataSource.eliminarTrabajo(id);
  }

  // ============================================================
  // ========== TRABAJOS POR DÍA ================================
  // ============================================================

  /// Obtiene el trabajo registrado en una fecha específica
  @override
  Future<TrabajoDia?> obtenerTrabajoDiaPorFecha(DateTime fecha) async {
    final modelo = await dataSource.getTrabajoDiaPorFecha(fecha);

    if (modelo == null) return null;

    return modelo.toEntity();
  }

  /// Registra un trabajo en un día específico
  @override
  Future<TrabajoDia> agregarTrabajoDia(TrabajoDia trabajoDia) async {
    final model = trabajoDia.toModel();

    final id = await dataSource.insertarTrabajoDia(model);
    return trabajoDia.copyWith(id: id);
  }

  /// Actualiza la información de un día trabajado
  @override
  Future<TrabajoDia> actualizarTrabajoDia(TrabajoDia trabajoDia) async {
    final model = trabajoDia.toModel();

    await dataSource.actualizarTrabajoDia(model);
    return trabajoDia;
  }

  /// Elimina un registro de trabajo diario
  @override
  Future<void> eliminarTrabajoDia(int id) async {
    await dataSource.eliminarTrabajoDia(id);
  }

  // ============================================================
  // ========== TRABAJOS POR MES (CALENDARIO) ===================
  // ============================================================

  /// Obtiene el estado de cada día de un mes:
  /// - Si tiene registro
  /// - Si está pagado
  @override
  Future<List<EstadoDiaCalendario>> obtenerEstadoDiasPorMes(
    DateTime mes,
  ) async {
    final resultados = await dataSource.getEstadosDiasCalendarioPorMes(mes);

    return resultados.map((map) {
      final model = EstadoDiaCalendarioModel.fromMap(map);

      return EstadoDiaCalendario(
        fecha: model.fecha,
        tieneRegistro: model.tieneRegistro,
        estaPagado: model.estaPagado,
      );
    }).toList();
  }

  // ============================================================
  // ========== TRABAJOS POR SEMANA / RANGO =====================
  // ============================================================

  /// Obtiene los trabajos entre dos fechas (semana, quincena, etc.)
  @override
  Future<List<TrabajoDia>> obtenerTrabajosDiaPorRango(
    DateTime inicio,
    DateTime fin,
  ) async {
    final modelos = await dataSource.getTrabajosEntreFechas(inicio, fin);

    return modelos.map((m) => m.toEntity()).toList();
  }

  /// Actualiza el estado de pago de un rango completo de fechas
  @override
  Future<void> actualizarEstadoPagoPorRango(
    DateTime inicio,
    DateTime fin,
    bool estaPagado,
  ) async {
    try {
      await dataSource.actualizarEstadoPagoPorRango(inicio, fin, estaPagado);
    } catch (e) {
      throw Exception('Error en repositorio al actualizar estado de pago: $e');
    }
  }

  @override
  Future<void> eliminarSemanaPagada(DateTime inicioSemana) async {
    await dataSource.eliminarSemanaPagada(inicioSemana);
  }

  @override
  Future<void> guardarSemanaPagada(SemanaPagada semana) async {
    final model = SemanaPagadaModel.fromEntity(semana);

    await dataSource.insertarSemanaPagada(model);
  }

  @override
  Future<bool> estaSemanaBloqueada(DateTime fecha) async {
    return dataSource.existeSemanaPagada(fecha);
  }
}
