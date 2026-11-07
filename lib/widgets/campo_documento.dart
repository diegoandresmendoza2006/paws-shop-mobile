import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/validadores.dart';

/// Documento de identidad: lista para el tipo (CC, CE o Pasaporte) y caja para el número.
/// El estado del tipo lo guarda la pantalla ([tipo] y [alCambiarTipo]).
class CampoDocumento extends StatelessWidget {
  final String tipo;
  final ValueChanged<String> alCambiarTipo;
  final TextEditingController controlador;

  const CampoDocumento({
    super.key,
    required this.tipo,
    required this.alCambiarTipo,
    required this.controlador,
  });

  static const tipos = {
    'CC': 'Cédula de ciudadanía',
    'CE': 'Cédula de extranjería',
    'PAS': 'Pasaporte',
  };

  @override
  Widget build(BuildContext context) {
    final esPasaporte = tipo == 'PAS';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Documento de identidad',
            style: TextStyle(fontWeight: FontWeight.w600),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFB71C1C))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: tipo,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: tipos.entries
                    .map((e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.key),
                        ))
                    .toList(),
                onChanged: (nuevo) {
                  if (nuevo != null) alCambiarTipo(nuevo);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controlador,
                validator: (v) => validarDocumento(tipo, v),
                keyboardType: esPasaporte ? TextInputType.text : TextInputType.number,
                inputFormatters: [
                  esPasaporte
                      ? FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))
                      : FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: esPasaporte ? 20 : 12,
                decoration: InputDecoration(
                  hintText: esPasaporte ? 'Ej: AB123456' : 'Ej: 1012345678',
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(tipos[tipo] ?? '', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
