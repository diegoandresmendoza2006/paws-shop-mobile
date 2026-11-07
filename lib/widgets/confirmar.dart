import 'package:flutter/material.dart';

/// Ventana "¿Seguro?": devuelve true si el usuario confirma.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Confirmar',
  bool peligroso = false,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogo, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: peligroso
              ? FilledButton.styleFrom(backgroundColor: const Color(0xFFB71C1C))
              : null,
          onPressed: () => Navigator.pop(dialogo, true),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}
