import 'package:flutter/material.dart';
import 'package:mi_semana/core/services/notification_service.dart';
import 'package:mi_semana/features/setting/presentation/screens/settings_screen.dart';
import 'package:mi_semana/features/setting/presentation/viewmodels/settings_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/screens/catalog_work_screen.dart';
import 'package:provider/provider.dart';

class BottomAppBarWidget extends StatelessWidget {
  const BottomAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de pantalla
    final size = MediaQuery.of(context).size;

    // Definir breakpoint para pantallas pequeñas
    final bool isSmallScreen = size.height < 700 || size.width < 360;

    // Altura dinámica del BottomAppBar
    final double barHeight = isSmallScreen ? 56 : 70;

    return BottomAppBar(
      color: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).scaffoldBackgroundColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 12.0,
      height: barHeight,
      clipBehavior: Clip.antiAlias,

      // Padding adaptativo
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón Ajustes
            BottomBarItem(
              icon: Icons.settings,
              label: 'Ajustes',
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) =>
                          SettingsViewModel(NotificationService()),
                      child: const SettingsScreen(),
                    ),
                  ),
                );
              },
            ),

            // Botón Trabajos
            BottomBarItem(
              icon: Icons.work,
              label: 'Trabajos',
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CatalogWorkScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isSmallScreen;

  const BottomBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSmallScreen,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        // Padding más compacto en pantallas pequeñas
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),

        // Layout adaptable
        child: isSmallScreen
            // En pantallas pequeñas: solo icono
            ? Icon(
                icon,
                color: color,
                size: 24,
              )

            // En pantallas normales: icono + texto
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}