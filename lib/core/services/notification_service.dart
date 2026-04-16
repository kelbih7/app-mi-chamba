import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../navigation/notification_router.dart';

/// ============================================================================
/// NOTIFICATION SERVICE
/// Infraestructura de notificaciones locales.
/// Maneja permisos, canales y scheduling.
/// NO contiene navegación ni lógica de dominio.
/// ============================================================================

class NotificationService {
  /// --------------------------------------------------------------------------
  /// SINGLETON
  /// --------------------------------------------------------------------------

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// --------------------------------------------------------------------------
  /// CONSTANTS
  /// --------------------------------------------------------------------------

  static const int _dailyNotificationId = 0;

  static const String _dailyChannelId = 'daily_reminder_channel';
  static const String _dailyChannelName = 'Recordatorios Diarios';
  static const String _dailyChannelDescription =
      'Notificaciones para recordatorios diarios';

  /// --------------------------------------------------------------------------
  /// INITIALIZATION
  /// --------------------------------------------------------------------------

  Future<void> initialize() async {
    try {
      // Esto solo verifica que la zona horaria está configurada
      tz.TZDateTime.now(tz.local);
    } catch (e) {
      // Fallback por si acaso
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Lima'));
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _createNotificationChannels();

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );
  }

  /// --------------------------------------------------------------------------
  /// TAP HANDLER
  /// --------------------------------------------------------------------------

  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    NotificationRouter.openTodayFromNotification();
  }

  /// --------------------------------------------------------------------------
  /// CHANNELS
  /// --------------------------------------------------------------------------

  Future<void> _createNotificationChannels() async {
    const dailyChannel = AndroidNotificationChannel(
      _dailyChannelId,
      _dailyChannelName,
      description: _dailyChannelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(dailyChannel);
  }

  /// --------------------------------------------------------------------------
  /// PERMISSIONS
  /// --------------------------------------------------------------------------

  Future<bool> requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get arePermissionsGranted async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// --------------------------------------------------------------------------
  /// SCHEDULING
  /// --------------------------------------------------------------------------

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    try {
      /// cancelar anterior si existe
      await cancelDailyNotification();

      const title = '¿Registraste tus trabajos de hoy?';
      const body = 'Aún estás a tiempo de guardar tus actividades del día.';

      final androidDetails = AndroidNotificationDetails(
        _dailyChannelId,
        _dailyChannelName,
        channelDescription: _dailyChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      final details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        _dailyNotificationId,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  /// --------------------------------------------------------------------------
  /// TIME
  /// --------------------------------------------------------------------------

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// --------------------------------------------------------------------------
  /// CANCELLATION
  /// --------------------------------------------------------------------------

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  Future<void> cancelDailyNotification() async {
    try {
      await _notifications.cancel(_dailyNotificationId);
    } catch (_) {}
  }
}
