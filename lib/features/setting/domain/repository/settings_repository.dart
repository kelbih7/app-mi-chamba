// features/setting/domain/repositories/settings_repository.dart
import 'package:mi_semana/features/setting/domain/entities/data_reset_result.dart';

abstract class SettingsRepository {
  Future<DataResetResult> resetApplicationData();
  // Podrías añadir más métodos relacionados con settings
}
