import 'package:flutter/material.dart';
import 'package:mi_semana/features/setting/presentation/viewmodels/settings_viewmodel.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mi_semana/features/work/presentation/screens/calendar_screen.dart';

class NotificationIntroScreen extends StatelessWidget {
  const NotificationIntroScreen({super.key});

  static const _notificationIntroSeenKey = 'notification_intro_seen';
  Future<void> _enableNotifications(BuildContext context) async {
    final settingsVM = context.read<SettingsViewModel>();

    // usa la misma lógica centralizada
    await settingsVM.setNotificationsEnabled(true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationIntroSeenKey, true);

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );
  }

  Future<void> _skip(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationIntroSeenKey, true);

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones'), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 90,
                          color: primaryColor,
                        ),

                        const SizedBox(height: 40),

                        const Text(
                          'Activa las notificaciones',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Activa las notificaciones para no olvidar registrar tus días trabajados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, height: 1.4),
                        ),

                        const SizedBox(height: 20),

                        const Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• Recordatorio diario de registro.',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '• Aviso semanal para revisar tu semana.',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '• Alerta si olvidaste registrar el día anterior.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Puedes desactivar o modificar estas notificaciones en cualquier momento desde Ajustes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _enableNotifications(context),
                            child: const Text('Activar notificaciones'),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () => _skip(context),
                          child: const Text('Ahora no'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
