import 'dart:typed_data';

/// Una foto que la persona acaba de elegir de su galería y todavía no se ha subido.
class FotoNueva {
  final Uint8List bytes;
  final String nombre;
  const FotoNueva(this.bytes, this.nombre);
}
