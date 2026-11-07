import 'package:flutter/material.dart';

import 'confirmar.dart';

/// Segunda pregunta cuando la cuenta tiene historial: ¿borrar también sus adopciones y compras?
/// Llama a [alConfirmar] solo si el administrador acepta.
Future<void> preguntarEliminarTodo(
  BuildContext context, {
  required String nombre,
  required VoidCallback alConfirmar,
}) async {
  final ok = await confirmar(
    context,
    titulo: '$nombre tiene historial',
    mensaje: 'Tiene solicitudes de adopción o compras registradas.\n\n'
        'Si continúas se borrará TAMBIÉN todo ese historial (solicitudes, seguimientos y pedidos) y '
        'las mascotas que haya adoptado volverán a quedar disponibles. Las ventas ya no aparecerán '
        'en los reportes. Esta acción no se puede deshacer.',
    textoConfirmar: 'Eliminar todo',
    peligroso: true,
  );
  if (ok) alConfirmar();
}
