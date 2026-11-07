import 'package:flutter/material.dart';

import '../bloc/aviso.dart';

/// Muestra un [Aviso] como SnackBar (rojo si es un error).
void mostrarAviso(BuildContext context, Aviso aviso) {
  final mensajero = ScaffoldMessenger.of(context);
  mensajero.hideCurrentSnackBar();
  mensajero.showSnackBar(SnackBar(
    content: Text(aviso.texto),
    backgroundColor: aviso.esError ? const Color(0xFFB71C1C) : null,
  ));
}

/// Atajo para un texto suelto.
void mostrarTexto(BuildContext context, String texto, {bool esError = false}) =>
    mostrarAviso(context, Aviso(texto, esError: esError));
