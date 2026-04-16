import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// =========================================================================
/// FlagListenable
/// -------------------------------------------------------------------------
/// Adaptador que expone un estado booleano derivado de un [ChangeNotifier]
/// como un [ValueListenable<bool>].
///
/// ## Propósito
/// En arquitecturas basadas en ViewModels, es común manejar múltiples
/// banderas de estado (por ejemplo: carga, guardado, eliminación).
/// Sin embargo, muchos widgets solo necesitan observar un único estado
/// booleano y no todo el ViewModel.
///
/// Esta clase permite desacoplar widgets genéricos de la implementación
/// concreta del ViewModel, exponiendo únicamente el flag requerido.
///
/// ## Responsabilidades
/// - Escuchar cambios en un [ChangeNotifier].
/// - Extraer un valor booleano específico mediante un selector.
/// - Mantener sincronizado el valor del [ValueNotifier].
/// - Gestionar correctamente el ciclo de vida del listener.
///
/// ## Cuándo usarlo
/// - Cuando un widget solo necesita reaccionar a un flag puntual.
/// - Cuando se quiere evitar depender directamente del ViewModel completo.
/// - Cuando se desea reutilizar widgets que aceptan [ValueListenable<bool>].
class FlagListenable<T extends ChangeNotifier> extends ValueNotifier<bool> {
  /// Notificador de origen, normalmente un ViewModel.
  final T notifier;

  /// Función encargada de extraer el flag booleano desde el [notifier].
  ///
  /// Debe devolver siempre un valor booleano representando el estado actual.
  final bool Function(T) selector;

  /// Listener interno utilizado para sincronizar el valor del flag.
  late final VoidCallback _listener;

  /// Crea un [FlagListenable] a partir de un [ChangeNotifier] y un selector.
  ///
  /// El valor inicial se obtiene inmediatamente desde el [selector] y se
  /// mantiene actualizado mientras el [notifier] esté activo.
  FlagListenable(this.notifier, this.selector) : super(selector(notifier)) {
    _listener = () => value = selector(notifier);
    notifier.addListener(_listener);
  }

  /// Libera el listener registrado en el [ChangeNotifier].
  ///
  /// Es obligatorio llamar a este método cuando la instancia deja de usarse,
  /// para evitar fugas de memoria y listeners colgantes.
  @override
  void dispose() {
    notifier.removeListener(_listener);
    super.dispose();
  }
}

/// =========================================================================
/// FlagListenableBuilder
/// -------------------------------------------------------------------------
/// Widget de conveniencia que encapsula la creación y destrucción de un
/// [FlagListenable].
///
/// ## Propósito
/// Simplificar el uso de [FlagListenable] dentro del árbol de widgets,
/// evitando que cada pantalla o diálogo tenga que gestionar manualmente
/// su ciclo de vida.
///
/// Este widget se encarga de:
/// - Crear una única instancia de [FlagListenable].
/// - Liberar correctamente sus recursos al salir del árbol.
///
/// ## Beneficios
/// - Reduce código repetitivo.
/// - Centraliza la gestión del ciclo de vida.
/// - Facilita la reutilización de widgets reactivos a flags booleanos.
///
/// ## Cuándo usarlo
/// - Cuando un widget necesita reaccionar a un estado booleano del ViewModel.
/// - Cuando se busca evitar dependencias directas a `context.watch`
///   o `Provider` dentro de widgets de UI.
class FlagListenableBuilder<T extends ChangeNotifier> extends StatefulWidget {
  /// Notificador observado, normalmente un ViewModel.
  final T notifier;

  /// Selector que extrae el flag booleano desde el [notifier].
  final bool Function(T) selector;

  /// Función encargada de construir la UI a partir del [ValueListenable<bool>].
  ///
  /// Permite integrar fácilmente widgets que reaccionan a cambios de estado
  /// sin conocer el ViewModel completo.
  final Widget Function(ValueListenable<bool>) builder;

  const FlagListenableBuilder({
    super.key,
    required this.notifier,
    required this.selector,
    required this.builder,
  });

  @override
  State<FlagListenableBuilder<T>> createState() =>
      _FlagListenableBuilderState<T>();
}

/// Estado interno responsable de la gestión del ciclo de vida del
/// [FlagListenable].
///
/// Se asegura de:
/// - Crear una única instancia durante [initState].
/// - Liberar correctamente los recursos durante [dispose].
class _FlagListenableBuilderState<T extends ChangeNotifier>
    extends State<FlagListenableBuilder<T>> {
  late final FlagListenable<T> _listenable;

  @override
  void initState() {
    super.initState();

    // La instancia se crea una sola vez.
    // No debe inicializarse dentro de build para evitar recreaciones.
    _listenable = FlagListenable(widget.notifier, widget.selector);
  }

  @override
  void dispose() {
    // Garantiza la eliminación del listener interno.
    _listenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Delegación completa del renderizado al builder externo.
    return widget.builder(_listenable);
  }
}
