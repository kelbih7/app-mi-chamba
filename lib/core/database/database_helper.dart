import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mi_semana.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  // ============================================================
  // CREACIÓN DE TABLAS
  // ============================================================

  Future<void> _createTables(Database db) async {
    // Catálogo de trabajos
    await db.execute('''
    CREATE TABLE trabajos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL UNIQUE,
      pago_predeterminado REAL NOT NULL,
      color INTEGER,
      icono INTEGER
    )
    ''');

    // Registro diario
    await db.execute('''
    CREATE TABLE trabajos_dia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha INTEGER NOT NULL UNIQUE,
      esta_pagado INTEGER NOT NULL DEFAULT 0
    )
    ''');

    // Detalle por día
    await db.execute('''
    CREATE TABLE trabajos_dia_detalle (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      trabajo_dia_id INTEGER NOT NULL,
      trabajo_id INTEGER NOT NULL,
      cantidad INTEGER NOT NULL DEFAULT 1,
      pago REAL NOT NULL,
      FOREIGN KEY (trabajo_dia_id) REFERENCES trabajos_dia(id) ON DELETE CASCADE,
      FOREIGN KEY (trabajo_id) REFERENCES trabajos(id)
    )
    ''');

    // Semanas pagadas (bloqueo por rango)
    await db.execute('''
    CREATE TABLE semanas_pagadas (
      inicio_semana INTEGER PRIMARY KEY,
      fin_semana INTEGER NOT NULL,
      fecha_pago INTEGER NOT NULL
    )
    ''');

    // ============================================================
    // ÍNDICES
    // ============================================================

    await db.execute(
      'CREATE INDEX idx_trabajos_dia_fecha ON trabajos_dia(fecha)',
    );

    await db.execute(
      'CREATE INDEX idx_trabajos_dia_detalle_trabajo_dia_id '
      'ON trabajos_dia_detalle(trabajo_dia_id)',
    );

    await db.execute(
      'CREATE INDEX idx_semanas_pagadas_rango '
      'ON semanas_pagadas(inicio_semana, fin_semana)',
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
