/// Un mensaje corto para mostrar en un SnackBar ("Agregado al carrito").
/// Cada aviso es un objeto NUEVO, así el mismo texto dos veces seguidas se muestra dos veces.
class Aviso {
  final String texto;
  final bool esError;
  Aviso(this.texto, {this.esError = false});
}
