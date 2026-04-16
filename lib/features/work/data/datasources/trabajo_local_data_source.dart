import 'package:mi_semana/core/database/database_helper.dart';
import 'package:mi_semana/core/utils/date_day_mapper.dart';
import 'package:mi_semana/features/work/data/models/semana_pagada_model.dart';
import 'package:sqflite/sqflite.dart';

import '../models/trabajo_catalog_model.dart';
import '../models/trabajo_dia_model.dart';
import '../models/trabajo_dia_detalle_model.dart';

class TrabajoLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ============================================================
  // CATÁLOGO DE TRABAJOS
  // ============================================================

  Future<List<TrabajoCatalogoModel>> getTrabajos() async {
    final db = await _dbHelper.database;
    final maps = await db.query('trabajos', orderBy: 'nombre');
    return maps.map((m) => TrabajoCatalogoModel.fromMap(m)).toList();
  }

  Future<bool> existeNombre(String nombre, [int? id]) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'trabajos',
      where: id == null ? 'nombre = ?' : 'nombre = ? AND id != ?',
      whereArgs: id == null ? [nombre] : [nombre, id],
    );

    return result.isNotEmpty;
  }

  Future<int> insertarTrabajo(TrabajoCatalogoModel trabajo) async {
    if (await existeNombre(trabajo.nombre)) {
      throw Exception('El nombre del trabajo ya ha sido registrado.');
    }

    final db = await _dbHelper.database;
    return db.insert('trabajos', trabajo.toMap());
  }

  Future<int> actualizarTrabajo(TrabajoCatalogoModel trabajo) async {
    if (await existeNombre(trabajo.nombre, trabajo.id)) {
      throw Exception('El nombre del trabajo no está disponible.');
    }

    final db = await _dbHelper.database;
    return db.update(
      'trabajos',
      trabajo.toMap(),
      where: 'id = ?',
      whereArgs: [trabajo.id],
    );
  }

  Future<int> eliminarTrabajo(int id) async {
    final db = await _dbHelper.database;
    return db.delete('trabajos', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // TRABAJOS POR DÍA
  // ============================================================

  Future<int> insertarTrabajoDia(TrabajoDiaModel dia) async {
    final db = await _dbHelper.database;

    final diaNormalizado = TrabajoDiaModel(
      fecha: DateDayMapper.toLocalDay(dia.fecha),
      estaPagado: dia.estaPagado,
      detalles: dia.detalles,
    );

    return db.transaction<int>((txn) async {
      final diaId = await txn.insert('trabajos_dia', diaNormalizado.toMap());

      for (final detalle in dia.detalles) {
        await txn.insert(
          'trabajos_dia_detalle',
          TrabajoDiaDetalleModel(
            trabajoDiaId: diaId,
            trabajoId: detalle.trabajoId,
            cantidad: detalle.cantidad,
            pago: detalle.pago,
          ).toMap(),
        );
      }

      return diaId;
    });
  }

  Future<void> actualizarTrabajoDia(TrabajoDiaModel dia) async {
    final db = await _dbHelper.database;

    final diaNormalizado = TrabajoDiaModel(
      id: dia.id,
      fecha: DateDayMapper.toLocalDay(dia.fecha),
      estaPagado: dia.estaPagado,
      detalles: dia.detalles,
    );

    await db.transaction((txn) async {
      await txn.update(
        'trabajos_dia',
        diaNormalizado.toMap(),
        where: 'id = ?',
        whereArgs: [dia.id],
      );

      await txn.delete(
        'trabajos_dia_detalle',
        where: 'trabajo_dia_id = ?',
        whereArgs: [dia.id],
      );

      for (final detalle in dia.detalles) {
        await txn.insert(
          'trabajos_dia_detalle',
          TrabajoDiaDetalleModel(
            trabajoDiaId: dia.id!,
            trabajoId: detalle.trabajoId,
            cantidad: detalle.cantidad,
            pago: detalle.pago,
          ).toMap(),
        );
      }
    });
  }

  Future<void> eliminarTrabajoDia(int id) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.delete(
        'trabajos_dia_detalle',
        where: 'trabajo_dia_id = ?',
        whereArgs: [id],
      );
      await txn.delete('trabajos_dia', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<TrabajoDiaModel?> getTrabajoDiaPorFecha(DateTime fecha) async {
    final db = await _dbHelper.database;

    final fechaMs = DateDayMapper.toLocalDayMillis(fecha);

    final maps = await db.query(
      'trabajos_dia',
      where: 'fecha = ?',
      whereArgs: [fechaMs],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final entry = maps.first;

    final detalleMaps = await db.query(
      'trabajos_dia_detalle',
      where: 'trabajo_dia_id = ?',
      whereArgs: [entry['id']],
    );

    return TrabajoDiaModel.fromMap(
      entry,
      detalles: detalleMaps.map(TrabajoDiaDetalleModel.fromMap).toList(),
    );
  }

  // ============================================================
  // CALENDARIO MENSUAL
  // ============================================================

  Future<List<Map<String, dynamic>>> getEstadosDiasCalendarioPorMes(
    DateTime mes,
  ) async {
    final db = await _dbHelper.database;

    final inicio = DateDayMapper.toLocalDayMillis(
      DateTime(mes.year, mes.month, 1),
    );
    final fin = DateDayMapper.toLocalDayMillis(
      DateTime(mes.year, mes.month + 1, 0),
    );

    return db.rawQuery(
      '''
      SELECT
        fecha,
        1 AS tiene_registro,
        MIN(esta_pagado) AS esta_pagado
      FROM trabajos_dia
      WHERE fecha BETWEEN ? AND ?
      GROUP BY fecha
      ORDER BY fecha ASC
      ''',
      [inicio, fin],
    );
  }

  // ============================================================
  // RANGOS
  // ============================================================

  Future<List<TrabajoDiaModel>> getTrabajosEntreFechas(
    DateTime inicio,
    DateTime fin,
  ) async {
    final db = await _dbHelper.database;

    final inicioMs = DateDayMapper.toLocalDayMillis(inicio);
    final finMs = DateDayMapper.toLocalDayMillis(fin);

    final diasMaps = await db.query(
      'trabajos_dia',
      where: 'fecha BETWEEN ? AND ?',
      whereArgs: [inicioMs, finMs],
      orderBy: 'fecha ASC',
    );

    if (diasMaps.isEmpty) return [];

    final ids = diasMaps.map((e) => e['id'] as int).toList();

    final detallesMaps = await db.query(
      'trabajos_dia_detalle',
      where: 'trabajo_dia_id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );

    final detallesPorDia = <int, List<TrabajoDiaDetalleModel>>{};

    for (final map in detallesMaps) {
      final d = TrabajoDiaDetalleModel.fromMap(map);
      detallesPorDia.putIfAbsent(d.trabajoDiaId, () => []).add(d);
    }

    return diasMaps.map((map) {
      final id = map['id'] as int;
      return TrabajoDiaModel.fromMap(map, detalles: detallesPorDia[id] ?? []);
    }).toList();
  }

  Future<void> actualizarEstadoPagoPorRango(
    DateTime inicio,
    DateTime fin,
    bool estaPagado,
  ) async {
    final db = await _dbHelper.database;

    final inicioMs = DateDayMapper.toLocalDayMillis(inicio);
    final finMs = DateDayMapper.toLocalDayMillis(fin);

    await db.update(
      'trabajos_dia',
      {'esta_pagado': estaPagado ? 1 : 0},
      where: 'fecha BETWEEN ? AND ?',
      whereArgs: [inicioMs, finMs],
    );
  }

  // ============================================================
  // SEMANA PAGADA
  // ============================================================
  Future<void> insertarSemanaPagada(SemanaPagadaModel semana) async {
    final db = await _dbHelper.database;

    final inicioMs = DateDayMapper.toLocalDayMillis(semana.inicioSemana);
    final finMs = DateDayMapper.toLocalDayMillis(semana.finSemana);
    final fechaPagoMs = DateDayMapper.toLocalDayMillis(semana.fechaPago);

    await db.insert('semanas_pagadas', {
      'inicio_semana': inicioMs,
      'fin_semana': finMs,
      'fecha_pago': fechaPagoMs,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> eliminarSemanaPagada(DateTime inicioSemana) async {
    final db = await _dbHelper.database;

    final inicioMs = DateDayMapper.toLocalDayMillis(inicioSemana);

    await db.delete(
      'semanas_pagadas',
      where: 'inicio_semana = ?',
      whereArgs: [inicioMs],
    );
  }

  Future<bool> existeSemanaPagada(DateTime inicioSemana) async {
    final db = await _dbHelper.database;

    final inicioMs = DateDayMapper.toLocalDayMillis(inicioSemana);

    final result = await db.query(
      'semanas_pagadas',
      columns: ['inicio_semana'],
      where: 'inicio_semana = ?',
      whereArgs: [inicioMs],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}
