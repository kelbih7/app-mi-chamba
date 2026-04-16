// features/setting/data/datasources/settings_local_data_source.dart
import 'package:mi_semana/core/database/database_helper.dart';
import 'package:mi_semana/features/setting/data/models/data_reset_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SettingsLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  SettingsLocalDataSource();

  Future<DataResetModel> resetAllData() async {
    final db = await _dbHelper.database;

    /// limpiar preferencias primero
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    /// luego limpiar base de datos
    return await db.transaction((txn) async {
      final trabajosCount =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM trabajos'),
          ) ??
          0;

      final diasCount =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM trabajos_dia'),
          ) ??
          0;

      final detallesCount =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM trabajos_dia_detalle'),
          ) ??
          0;

      await txn.delete('trabajos_dia_detalle');
      await txn.delete('trabajos_dia');
      await txn.delete('trabajos');

      return DataResetModel(
        resetTimestamp: DateTime.now(),
        trabajosDeleted: trabajosCount,
        trabajosDiaDeleted: diasCount,
        detallesDeleted: detallesCount,
      );
    });
  }
}
