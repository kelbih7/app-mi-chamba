import 'package:flutter/material.dart';
import 'package:mi_semana/core/themes/themes_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider();

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? ThemesApp.darkTheme : ThemesApp.lightTheme;

  // Llamar al iniciar la app
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    _saveTheme(isDark);
    notifyListeners();
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  /// 🔄 Método agregado:
  /// Permite actualizar el tema sin guardar en disco (por ejemplo,
  /// al restaurar desde un contenedor DI o estado persistido en memoria)
  void updateTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}
