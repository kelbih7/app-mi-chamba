import 'package:flutter/material.dart';
import 'package:mi_semana/features/setting/domain/usecases/reset_application_data.dart';
import 'package:mi_semana/features/setting/domain/entities/data_reset_result.dart';

class DataResetViewModel with ChangeNotifier {
  final ResetApplicationData resetApplicationData;

  bool _isResetting = false;
  bool get isResetting => _isResetting;

  DataResetViewModel(this.resetApplicationData);

  Future<bool> resetAllData() async {
    _isResetting = true;
    notifyListeners();

    try {
      final DataResetResult result = await resetApplicationData();

      await Future.delayed(const Duration(milliseconds: 700));

      return result.success;
    } finally {
      _isResetting = false;
      notifyListeners();
    }
  }
}
