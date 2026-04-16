class ValidateInputs {
  /// Valida si un campo de texto está vacío o nulo.
  /// Retorna un mensaje de error si está vacío.
  static String? validateIsEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName no puede estar vacío.';
    }
    return null;
  }
}
