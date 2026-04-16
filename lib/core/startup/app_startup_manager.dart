import 'package:shared_preferences/shared_preferences.dart';
import 'startup_result.dart';

// -----------------------------------------------------------------------------
// APP STARTUP MANAGER
// -----------------------------------------------------------------------------
// Esta clase se encarga de decidir la ruta inicial de la aplicación.
//
// Responsabilidades:
// 1. Leer configuraciones persistidas (SharedPreferences)
// 2. Determinar si el usuario ya completó ciertos flujos iniciales
// 3. Retornar la ruta que debe tomar la app al iniciar
//
// Nota:
// No contiene lógica de UI ni navegación directa.
// Solo decide el flujo de arranque basado en estado persistido.
// -----------------------------------------------------------------------------
class AppStartupManager {
  // Clave usada para saber si el usuario ya vio la introducción de notificaciones
  static const _notificationIntroSeenKey = 'notification_intro_seen';

  Future<StartupResult> determineStartupRoute() async {
    // Obtener instancia de almacenamiento local
    final prefs = await SharedPreferences.getInstance();

    // Leer si el usuario ya vio la pantalla introductoria
    final introSeen = prefs.getBool(_notificationIntroSeenKey) ?? false;

    // -------------------------------------------------------------------------
    // Decisión de flujo de arranque
    // -------------------------------------------------------------------------
    // Si el usuario NO ha visto la introducción → mostrarla
    if (!introSeen) {
      return StartupResult.showNotificationIntro;
    }

    // Si ya la vio → ir directamente a la pantalla principal
    return StartupResult.goToHome;
  }
}
