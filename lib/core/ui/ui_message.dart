/// Representa un mensaje de interfaz de usuario.
///
/// Esta clase se utiliza para encapsular información que será mostrada
/// al usuario, como notificaciones, alertas o mensajes de resultado
/// de una operación.
class UiMessage {
  /// Texto del mensaje que se mostrará en la interfaz.
  final String text;

  /// Indica si el mensaje representa un resultado exitoso.
  ///
  /// - `true`: el mensaje corresponde a una operación exitosa.
  /// - `false`: el mensaje corresponde a un error o advertencia.
  final bool success;

  /// Crea una instancia de [UiMessage].
  ///
  /// Ambos parámetros son obligatorios para garantizar que el mensaje
  /// tenga contenido y un estado claramente definido.
  UiMessage({required this.text, required this.success});
}
