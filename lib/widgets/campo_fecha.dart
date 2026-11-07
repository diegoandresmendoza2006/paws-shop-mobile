import 'package:flutter/material.dart';

import '../utils/formato.dart';

/// Campo de fecha de nacimiento: al tocarlo abre el calendario.
/// Solo deja elegir fechas de personas mayores de edad.
class CampoFecha extends StatefulWidget {
  final String etiqueta;
  final String? ayuda;
  final DateTime? fechaInicial;
  final ValueChanged<DateTime> alCambiar;

  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.alCambiar,
    this.ayuda,
    this.fechaInicial,
  });

  @override
  State<CampoFecha> createState() => _CampoFechaState();
}

class _CampoFechaState extends State<CampoFecha> {
  final TextEditingController _controlador = TextEditingController();
  DateTime? _elegida;

  @override
  void initState() {
    super.initState();
    final inicial = widget.fechaInicial;
    if (inicial != null) {
      _elegida = inicial;
      _controlador.text = fechaLegible(inicial);
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _elegir() async {
    final maxima = fechaMaximaNacimiento();
    var inicial = _elegida ?? maxima;
    if (inicial.isAfter(maxima)) inicial = maxima;
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(1920),
      lastDate: maxima,
    );
    if (fecha == null) return;
    setState(() {
      _elegida = fecha;
      _controlador.text = fechaLegible(fecha);
    });
    widget.alCambiar(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.etiqueta,
            style: const TextStyle(fontWeight: FontWeight.w600),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFB71C1C))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _controlador,
          readOnly: true,
          onTap: _elegir,
          validator: (_) =>
              _elegida == null ? 'Elige tu fecha de nacimiento' : null,
          decoration: const InputDecoration(
            hintText: 'dd/mm/aaaa',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today_outlined),
          ),
        ),
        if (widget.ayuda != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.ayuda!,
                style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}
