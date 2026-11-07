import 'package:flutter/material.dart';

/// Pregunta de Sí / No que forma parte del Form (se valida con formKey.currentState!.validate()).
class PreguntaSiNo extends FormField<bool> {
  PreguntaSiNo({
    super.key,
    required String pregunta,
    required ValueChanged<bool> alCambiar,
  }) : super(
          validator: (valor) => valor == null ? 'Elige una opción' : null,
          builder: (campo) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: pregunta,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    children: const [
                      TextSpan(
                          text: ' *',
                          style: TextStyle(color: Color(0xFFB71C1C))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: true, label: Text('Sí')),
                      ButtonSegment(value: false, label: Text('No')),
                    ],
                    selected: campo.value == null ? <bool>{} : {campo.value!},
                    onSelectionChanged: (seleccion) {
                      if (seleccion.isEmpty) return;
                      campo.didChange(seleccion.first);
                      alCambiar(seleccion.first);
                    },
                  ),
                ),
                if (campo.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      campo.errorText!,
                      style: const TextStyle(
                          color: Color(0xFFB71C1C), fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
}
