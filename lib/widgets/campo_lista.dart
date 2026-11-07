import 'package:flutter/material.dart';

/// Lista desplegable con la etiqueta arriba (igual que [CampoTexto]).
class CampoLista<T> extends StatelessWidget {
  final String etiqueta;
  final T? valor;
  final List<DropdownMenuItem<T>> opciones;
  final ValueChanged<T?> alCambiar;
  final bool obligatorio;
  final String? Function(T?)? validador;

  const CampoLista({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.alCambiar,
    this.obligatorio = true,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: etiqueta,
            style: const TextStyle(fontWeight: FontWeight.w600),
            children: [
              if (obligatorio)
                const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFB71C1C))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: valor,
          isExpanded: true,
          items: opciones,
          onChanged: alCambiar,
          validator: validador,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
