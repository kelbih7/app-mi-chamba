// features/setting/domain/entities/data_reset_result.dart
class DataResetResult {
  final bool success;
  final String message;
  final int deletedRecordsCount;
  final DateTime resetTimestamp;

  const DataResetResult({
    required this.success,
    required this.message,
    required this.deletedRecordsCount,
    required this.resetTimestamp,
  });

  // Podrías añadir métodos de conveniencia
  bool get hasRecordsDeleted => deletedRecordsCount > 0;
}
