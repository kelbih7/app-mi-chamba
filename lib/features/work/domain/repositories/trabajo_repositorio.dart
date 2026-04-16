import 'package:mi_semana/features/work/domain/entities/estado_dia_calendario.dart';
import 'package:mi_semana/features/work/domain/entities/semana_pagada.dart';

import '../entities/trabajo_catalogo.dart';
import '../entities/trabajo_dia.dart';

/// El repositorio define las operaciones que la capa de dominio necesita.
/// Aquí declaramos qué cosas se pueden hacer con los "Trabajos" (tipos de labor)
/// y con los "Trabajos por Día" (lo que realmente se registra en el calendario).
///
/// La implementación concreta (en `data/`) usará SQLite, pero desde la capa
/// de dominio solo nos interesa la **abstracción**.
abstract class TrabajoRepositorio {
  // ------------------------------
  // CRUD de TRABAJOS base (tipos de labor)
  // ------------------------------

  /// Obtener todos los tipos de trabajo/labor registrados
  /// (Ejemplo: Cargar, Descargar, Repartir...).
  Future<List<Trabajo>> obtenerTrabajos();

  /// Agregar un nuevo tipo de trabajo.
  /// (Se guarda el nombre y el pago por defecto).
  Future<Trabajo> agregarTrabajo(Trabajo trabajo);

  /// Actualizar un tipo de trabajo existente.
  /// (Por ejemplo, cambiar el pago por defecto de "Cargar").
  Future<Trabajo> actualizarTrabajo(Trabajo trabajo);

  /// Eliminar un tipo de trabajo por su ID.
  /// Devuelve el número de filas afectadas (0 si no existía).
  Future<int> eliminarTrabajo(int id);

  // ------------------------------
  // CRUD de TRABAJOS por DÍA (registros diarios)
  // ------------------------------

  /// Registrar un nuevo trabajo en un día específico.
  /// (Ejemplo: el 2025-09-18 se hizo 2 cargas y 1 descarga).
  Future<TrabajoDia> agregarTrabajoDia(TrabajoDia trabajoDia);

  /// Actualizar un trabajo ya registrado en un día.
  /// (Ejemplo: corregir la cantidad o el pago).
  Future<TrabajoDia> actualizarTrabajoDia(TrabajoDia trabajoDia);

  /// Obtener los trabajos registrados en una echa especifica.
  Future<TrabajoDia?> obtenerTrabajoDiaPorFecha(DateTime fecha);

  /// Eliminar un tipo de trabajo por dia usando su ID.
  Future<void> eliminarTrabajoDia(int id);
  // ------------------------------
  // CRUD de TRABAJOS por SEMANAS
  // ------------------------------

  /// Trae todos los registros exsitentes en la db
  Future<List<EstadoDiaCalendario>> obtenerEstadoDiasPorMes(DateTime mes);

  /// Obtener los trabajos registrados entre dos fechas.
  Future<List<TrabajoDia>> obtenerTrabajosDiaPorRango(
    DateTime inicio,
    DateTime fin,
  );

  /// Actualiza el estado de pago de todos los días en un rango
  Future<void> actualizarEstadoPagoPorRango(
    DateTime inicio,
    DateTime fin,
    bool estaPagado,
  );

  /// Registra que una semana fue pagada
  Future<void> guardarSemanaPagada(SemanaPagada semana);

  /// Elimina el registro de semana pagada (rollback / desmarcar)
  Future<void> eliminarSemanaPagada(DateTime inicioSemana);

  Future<bool> estaSemanaBloqueada(DateTime fecha);
}
