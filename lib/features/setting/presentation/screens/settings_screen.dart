import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mi_semana/core/navigation/navigator_key.dart';
import 'package:mi_semana/core/themes/theme_provider.dart';
import 'package:mi_semana/core/ui/screens/splash_screen.dart';
import 'package:mi_semana/core/ui/toast/app_toast.dart';
import 'package:mi_semana/core/ui/widgets/restart_widget.dart';
import 'package:mi_semana/features/setting/presentation/viewmodels/data_reset_viewmodel.dart';
import 'package:mi_semana/features/setting/presentation/viewmodels/settings_viewmodel.dart';
import 'package:provider/provider.dart';

/// Pantalla principal de configuración (Ajustes)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return const _SettingsScreenContent();
  }
}

class _SettingsScreenContent extends StatefulWidget {
  const _SettingsScreenContent();

  @override
  State<_SettingsScreenContent> createState() => _SettingsScreenContentState();
}

class _SettingsScreenContentState extends State<_SettingsScreenContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settingsVM = context.watch<SettingsViewModel>();
    final uiMessage = settingsVM.uiMessage;

    if (uiMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        AppToast.show(
          context,
          message: uiMessage.text,
          isSuccess: uiMessage.success,
        );

        settingsVM.clearUiMessage();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPermissions();
    }
  }

  void _syncPermissions() {
    context.read<SettingsViewModel>().syncWithSystemPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final resetVM = context.watch<DataResetViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ajustes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(themeProvider),

          const SizedBox(height: 20),

          _buildNotificationsSection(settingsVM),

          const SizedBox(height: 20),

          _buildResetSection(resetVM),
        ],
      ),
    );
  }

  // ==========================================================
  // SECCIÓN TEMA
  // ==========================================================
  Widget _buildThemeSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: Icons.wb_sunny, title: "Tema"),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Modo oscuro"),
            subtitle: const Text("Cambia entre tema claro y oscuro"),
            value: themeProvider.isDarkMode,
            onChanged: themeProvider.toggleTheme,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECCIÓN NOTIFICACIONES
  // ==========================================================
  Widget _buildNotificationsSection(SettingsViewModel settingsVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Icons.notifications,
          title: "Notificaciones",
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Permitir notificaciones"),
                value: settingsVM.notificationsEnabled,
                onChanged: settingsVM.setNotificationsEnabled,
              ),

              if (settingsVM.notificationsEnabled) ...[
                _NotificationTile(
                  icon: Icons.access_time,
                  title: "Recordatorio diario",
                  timeLabel: settingsVM.dailyReminderFormatted,
                  enabled: settingsVM.dailyReminders,
                  onChanged: settingsVM.setDailyReminders,
                  onTap: settingsVM.dailyReminders
                      ? () => _selectDailyTime(context, settingsVM)
                      : null,
                ),

                _NotificationTile(
                  icon: Icons.warning_amber,
                  title: "Aviso si olvidaste ayer",
                  timeLabel: "09:00",
                  enabled: false, // inicia apagado
                  onChanged: (v) {
                    settingsVM.emitMessage(
                      "Esta función estará disponible en futuras actualizaciones",
                      success: true,
                    );
                  },
                  onTap: () {
                    settingsVM.emitMessage(
                      "Esta función estará disponible en futuras actualizaciones",
                      success: true,
                    );
                  },
                ),

                _NotificationTile(
                  icon: Icons.calendar_today,
                  title: "Resumen semanal",
                  timeLabel: "Dom 16:00",
                  enabled: false,
                  onChanged: (v) {
                    settingsVM.emitMessage(
                      "Esta función estará disponible en futuras actualizaciones",
                      success: true,
                    );
                  },
                  onTap: () {
                    settingsVM.emitMessage(
                      "Esta función estará disponible en futuras actualizaciones",
                      success: true,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // RESET
  // ==========================================================
  Widget _buildResetSection(DataResetViewModel resetVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Icons.delete_forever,
          title: "Restablecer datos",
        ),

        const SizedBox(height: 12),

        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            "Eliminar toda la información",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 6),

        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text("Esta acción es permanente, no se puede restablecer."),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: resetVM.isResetting
                  ? null
                  : () => _showResetConfirmation(context, resetVM),
              icon: resetVM.isResetting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_sweep),
              label: Text(
                resetVM.isResetting ? "Procesando..." : "Restablecer datos",
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DIÁLOGOS
  // ==========================================================
  void _showResetConfirmation(
    BuildContext context,
    DataResetViewModel resetVM,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                "Restablecer datos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Se eliminarán todos los datos guardados en la aplicación.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Esta acción es permanente y no se puede deshacer.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        final success = await resetVM.resetAllData();

                        if (!success) {
                          AppToast.show(
                            navigatorKey.currentContext!,
                            message:
                                "Ocurrió un error al restablecer los datos",
                            isSuccess: false,
                          );
                          return;
                        }
                        navigatorKey.currentState!.pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const SplashScreen(),
                          ),
                          (route) => false,
                        );

                        Future.microtask(() {
                          RestartWidget.restart();
                        });
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Restablecer"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDailyTime(
  BuildContext context,
  SettingsViewModel settingsVM,
) async {
  DateTime tempPickedTime = DateTime(
    0,
    0,
    0,
    settingsVM.dailyReminderTime.hour,
    settingsVM.dailyReminderTime.minute,
  );

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //  HANDLE (rayita)
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // TÍTULO
                const Text(
                  "Seleccionar hora",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // PICKER
                SizedBox(
                  height: 180,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: false,
                    initialDateTime: tempPickedTime,
                    onDateTimeChanged: (DateTime newDate) {
                      tempPickedTime = newDate;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // BOTONES
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(

                        onPressed: () async {
                          Navigator.pop(context);

                          final picked = TimeOfDay(
                            hour: tempPickedTime.hour,
                            minute: tempPickedTime.minute,
                          );

                          await settingsVM.setDailyReminderTime(picked);
                        },
                        child: const Text("Guardar"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}

/// HEADER DE SECCIÓN
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

/// TILE COMPACTO DE NOTIFICACIÓN
class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String timeLabel;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.timeLabel,
    required this.enabled,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon),
      title: Text(title),
      subtitle: enabled
          ? Text(
              "$timeLabel • tocar para cambiar",
              style: const TextStyle(fontSize: 12),
            )
          : const Text(
              "Activa para configurar",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

      trailing: Switch(value: enabled, onChanged: onChanged),
      onTap: onTap,
    );
  }
}
