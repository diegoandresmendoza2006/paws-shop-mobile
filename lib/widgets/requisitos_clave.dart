import 'package:flutter/material.dart';

import '../utils/colores.dart';
import '../utils/validadores.dart';

/// Lista que se va marcando mientras la persona escribe su contraseña:
/// en verde lo que ya cumple y en gris lo que todavía le falta.
class RequisitosClave extends StatelessWidget {
  final TextEditingController controlador;
  const RequisitosClave({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controlador,
      builder: (context, valor, _) {
        final requisitos = requisitosDeClave(valor.text);
        final completas = requisitos.where((r) => r.cumple).length;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(110),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tu contraseña debe tener ($completas de ${requisitos.length}):',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              for (final r in requisitos)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(r.cumple ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 18, color: r.cumple ? context.verdeFuerte : context.textoSecundario),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r.texto,
                            style: TextStyle(
                              fontSize: 13,
                              color: r.cumple ? context.verdeFuerte : context.textoSecundario,
                              fontWeight: r.cumple ? FontWeight.w600 : FontWeight.normal,
                            )),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
