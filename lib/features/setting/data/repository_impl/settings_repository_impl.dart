// features/setting/data/repositories/settings_repository_impl.dart
import 'package:mi_semana/features/setting/data/datasource/settings_local_data_source.dart';
import 'package:mi_semana/features/setting/domain/entities/data_reset_result.dart';
import 'package:mi_semana/features/setting/domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<DataResetResult> resetApplicationData() async {
    try {
      final resetModel = await localDataSource.resetAllData();

      return DataResetResult(
        success: true,
        message: 'Datos restablecidos correctamente',
        deletedRecordsCount:
            resetModel.trabajosDeleted +
            resetModel.trabajosDiaDeleted +
            resetModel.detallesDeleted,
        resetTimestamp: resetModel.resetTimestamp,
      );
    } catch (e) {
      return DataResetResult(
        success: false,
        message: 'Error al restablecer datos: $e',
        deletedRecordsCount: 0,
        resetTimestamp: DateTime.now(),
      );
    }
  }
}
