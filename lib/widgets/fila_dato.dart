import 'package:flutter/material.dart';

/// "Etiqueta: valor" para las pantallas de detalle.
class FilaDato extends StatelessWidget {
  final String etiqueta;
  final String? valor;
  const FilaDato({super.key, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    final texto = (valor == null || valor!.trim().isEmpty) ? '—' : valor!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
