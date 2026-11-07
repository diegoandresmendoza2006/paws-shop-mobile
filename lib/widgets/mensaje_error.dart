import 'package:flutter/material.dart';
import '../utils/colores.dart';

/// Caja roja con un mensaje de error dentro de un formulario.
class MensajeError extends StatelessWidget {
  final String mensaje;
  const MensajeError({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.rojoSuave,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.rojoFuerte),
      ),
      child: Text(mensaje, style: TextStyle(color: context.rojoFuerte)),
    );
  }
}
