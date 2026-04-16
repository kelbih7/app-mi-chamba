// features/setting/data/models/data_reset_model.dart
class DataResetModel {
  final DateTime resetTimestamp;
  final int trabajosDeleted;
  final int trabajosDiaDeleted;
  final int detallesDeleted;

  DataResetModel({
    required this.resetTimestamp,
    required this.trabajosDeleted,
    required this.trabajosDiaDeleted,
    required this.detallesDeleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'resetTimestamp': resetTimestamp.toIso8601String(),
      'trabajosDeleted': trabajosDeleted,
      'trabajosDiaDeleted': trabajosDiaDeleted,
      'detallesDeleted': detallesDeleted,
    };
  }
}
