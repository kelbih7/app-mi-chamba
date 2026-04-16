import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mi_semana/core/services/notification_service.dart';
import 'package:mi_semana/core/ui/screens/splash_screen.dart';
import 'package:mi_semana/core/ui/widgets/restart_widget.dart';
import 'package:mi_semana/features/setting/presentation/viewmodels/settings_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ============================================================
// CORE
// ============================================================

import 'package:mi_semana/core/navigation/navigator_key.dart';
import 'package:mi_semana/core/themes/theme_provider.dart';
import 'package:mi_semana/core/themes/themes_app.dart';

// ============================================================
// WORK - DATA LAYER
// ============================================================

import 'package:mi_semana/features/work/data/datasources/trabajo_local_data_source.dart';
import 'package:mi_semana/features/work/data/repositories/trabajo_repositorio_impl.dart';

// ============================================================
// WORK - DOMAIN LAYER (REPOSITORIES)
// ============================================================

import 'package:mi_semana/features/work/domain/repositories/trabajo_repositorio.dart';

// ============================================================
// WORK - DOMAIN LAYER (USE CASES)
// ============================================================

import 'package:mi_semana/features/work/domain/usecases/work/obtener_trabajos.dart';
import 'package:mi_semana/features/work/domain/usecases/work/agregar_trabajo.dart';
import 'package:mi_semana/features/work/domain/usecases/work/actualizar_trabajo.dart';
import 'package:mi_semana/features/work/domain/usecases/work/eliminar_trabajo.dart';

import 'package:mi_semana/features/work/domain/usecases/verificar_semana_pagada.dart';
import 'package:mi_semana/features/work/domain/usecases/obtener_estado_dias_mensual.dart';
import 'package:mi_semana/features/work/domain/usecases/obtener_resumen_semanal.dart';

import 'package:mi_semana/features/work/domain/usecases/daily_work/guardar_trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/usecases/daily_work/actualizar_trabajo_dia.dart';
import 'package:mi_semana/features/work/domain/usecases/daily_work/obtener_trabajo_dia_por_fecha.dart';
import 'package:mi_semana/features/work/domain/usecases/daily_work/eliminar_trabajo_dia.dart';

// ============================================================
// WORK - PRESENTATION LAYER
// ============================================================

import 'package:mi_semana/features/work/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/weekly_summary_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/catalog_work_viewmodel.dart';
import 'package:mi_semana/features/work/presentation/viewmodels/daily_work_registration_viewmodel.dart';

// ============================================================
// SETTINGS
// ============================================================

import 'package:mi_semana/features/setting/data/datasource/settings_local_data_source.dart';
import 'package:mi_semana/features/setting/data/repository_impl/settings_repository_impl.dart';
import 'package:mi_semana/features/setting/domain/repository/settings_repository.dart';
import 'package:mi_semana/features/setting/domain/usecases/reset_application_data.dart';
import 'package:mi_semana/features/setting/presentation/viewmodels/data_reset_viewmodel.dart';

// -----------------------------------------------------------------------------
// MAIN ENTRY POINT
// -----------------------------------------------------------------------------
// Aquí se inicializan:
// - Binding de Flutter
// - Orientación de pantalla
// - Zonas horarias
// - Servicio de notificaciones
// -----------------------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Inicializar zonas horarias
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Lima'));

  // Inicializar notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Iniciar app con capacidad de reinicio global
  runApp(RestartWidget(child: const MyApp()));
}

// -----------------------------------------------------------------------------
// ROOT WIDGET
// -----------------------------------------------------------------------------
// Configura:
// - Inyección de dependencias (Provider)
// - Tema (claro/oscuro)
// - Localización
// - Pantalla inicial (Splash)
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ============================================================
        // DATA SOURCES
        // ============================================================
        Provider<TrabajoLocalDataSource>(
          create: (_) => TrabajoLocalDataSource(),
        ),
        Provider<SettingsLocalDataSource>(
          create: (_) => SettingsLocalDataSource(),
        ),

        // ============================================================
        // REPOSITORIES
        // ============================================================
        Provider<TrabajoRepositorio>(
          create: (context) =>
              TrabajoRepositorioImpl(context.read<TrabajoLocalDataSource>()),
        ),
        Provider<SettingsRepository>(
          create: (context) =>
              SettingsRepositoryImpl(context.read<SettingsLocalDataSource>()),
        ),

        // ============================================================
        // USE CASES
        // ============================================================
        Provider<VerificarSemanaPagada>(
          create: (context) =>
              VerificarSemanaPagada(context.read<TrabajoRepositorio>()),
        ),
        Provider<ObtenerEstadoDiasMensual>(
          create: (context) =>
              ObtenerEstadoDiasMensual(context.read<TrabajoRepositorio>()),
        ),
        Provider<ObtenerResumenSemanal>(
          create: (context) =>
              ObtenerResumenSemanal(context.read<TrabajoRepositorio>()),
        ),
        Provider<ObtenerTrabajos>(
          create: (context) =>
              ObtenerTrabajos(context.read<TrabajoRepositorio>()),
        ),
        Provider<AgregarTrabajo>(
          create: (context) =>
              AgregarTrabajo(context.read<TrabajoRepositorio>()),
        ),
        Provider<ActualizarTrabajo>(
          create: (context) =>
              ActualizarTrabajo(context.read<TrabajoRepositorio>()),
        ),
        Provider<EliminarTrabajo>(
          create: (context) =>
              EliminarTrabajo(context.read<TrabajoRepositorio>()),
        ),
        Provider<GuardarTrabajoDia>(
          create: (context) => GuardarTrabajoDia(
            context.read<TrabajoRepositorio>(),
            context.read<VerificarSemanaPagada>(),
          ),
        ),
        Provider<ActualizarTrabajoDia>(
          create: (context) => ActualizarTrabajoDia(
            context.read<TrabajoRepositorio>(),
            context.read<VerificarSemanaPagada>(),
          ),
        ),
        Provider<ObtenerTrabajoDiaPorFecha>(
          create: (context) =>
              ObtenerTrabajoDiaPorFecha(context.read<TrabajoRepositorio>()),
        ),
        Provider<EliminarTrabajoDia>(
          create: (context) =>
              EliminarTrabajoDia(context.read<TrabajoRepositorio>()),
        ),
        Provider<ResetApplicationData>(
          create: (context) =>
              ResetApplicationData(context.read<SettingsRepository>()),
        ),

        // ============================================================
        // VIEWMODELS
        // ============================================================
        ChangeNotifierProvider(
          create: (context) => CatalogWorkViewmodel(
            obtenerTrabajosUseCase: context.read<ObtenerTrabajos>(),
            agregarTrabajoUseCase: context.read<AgregarTrabajo>(),
            actualizarTrabajoUseCase: context.read<ActualizarTrabajo>(),
            eliminarTrabajoUseCase: context.read<EliminarTrabajo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CalendarViewModel(
            obtenerEstadoDiasMensual: context.read<ObtenerEstadoDiasMensual>(),
            verificarSemanaPagada: context.read<VerificarSemanaPagada>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WeeklySummaryViewmodel(
            obtenerResumenSemanalUseCase: context.read<ObtenerResumenSemanal>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DailyWorkRegistrationViewmodel(
            guardarTrabajoDiaUseCase: context.read<GuardarTrabajoDia>(),
            actualizarTrabajoDiaUseCase: context.read<ActualizarTrabajoDia>(),
            obtenerTrabajoDiaPorFechaUseCase: context
                .read<ObtenerTrabajoDiaPorFecha>(),
            eliminarTrabajoDiaUseCase: context.read<EliminarTrabajoDia>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              DataResetViewModel(context.read<ResetApplicationData>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsViewModel(NotificationService()),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = ThemeProvider();
            provider.init();
            return provider;
          },
        ),
      ],

      // -------------------------------------------------------------------------
      // MATERIAL APP CONFIGURATION
      // -------------------------------------------------------------------------
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mi Chamba',
            navigatorKey: navigatorKey,

            // Temas
            theme: ThemesApp.lightTheme,
            darkTheme: ThemesApp.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            // Localización
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('es'), Locale('en')],

            // Pantalla inicial
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
