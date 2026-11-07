import 'package:flutter/material.dart';

/// Fila de chips para filtrar. [opciones] = texto que se ve -> valor que se envía ('' = todos).
class FiltroChips extends StatelessWidget {
  final Map<String, String> opciones;
  final String seleccion;
  final ValueChanged<String> alElegir;

  const FiltroChips({
    super.key,
    required this.opciones,
    required this.seleccion,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: opciones.entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.key),
                    selected: e.value == seleccion,
                    onSelected: (_) => alElegir(e.value),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
