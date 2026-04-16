/// Excepción base para violaciones de reglas de negocio.
/// No está pensada para UI, sino para proteger invariantes.
class DomainException implements Exception {
  final String code;

  const DomainException(this.code);

  @override
  String toString() => code;
}
