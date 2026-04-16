// features/setting/domain/usecases/reset_application_data.dart
import 'package:mi_semana/features/setting/domain/entities/data_reset_result.dart';
import 'package:mi_semana/features/setting/domain/repository/settings_repository.dart';

class ResetApplicationData {
  final SettingsRepository repository;

  ResetApplicationData(this.repository);

  Future<DataResetResult> call() async {
    return await repository.resetApplicationData();
  }
}
