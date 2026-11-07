import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de formulario reutilizable: etiqueta arriba (con * si es obligatorio) y caja de texto.
/// Si es de contraseña ([oculto]), muestra el "ojito" para ver u ocultar lo escrito.
class CampoTexto extends StatefulWidget {
  final String etiqueta;
  final TextEditingController controlador;
  final String? Function(String?)? validador;
  final String? pista;
  final TextInputType? teclado;
  final bool oculto; // true para contraseñas (activa el ojito)
  final int maxLineas;
  final int? maxLongitud;
  final bool obligatorio;
  final bool habilitado;
  final TextInputAction? accion;
  final List<TextInputFormatter>? formateadores;
  final ValueChanged<String>? alEnviar;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.validador,
    this.pista,
    this.teclado,
    this.oculto = false,
    this.maxLineas = 1,
    this.maxLongitud,
    this.obligatorio = true,
    this.habilitado = true,
    this.accion,
    this.formateadores,
    this.alEnviar,
  });

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  late bool _escondido = widget.oculto; // ¿se están escondiendo las letras ahora?

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.etiqueta,
            style: const TextStyle(fontWeight: FontWeight.w600),
            children: [
              if (widget.obligatorio)
                const TextSpan(
                    text: ' *', style: TextStyle(color: Color(0xFFB71C1C))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controlador,
          validator: widget.validador,
          keyboardType: widget.teclado,
          obscureText: _escondido,
          maxLines: widget.oculto ? 1 : widget.maxLineas,
          maxLength: widget.maxLongitud,
          enabled: widget.habilitado,
          textInputAction: widget.accion,
          inputFormatters: widget.formateadores,
          onFieldSubmitted: widget.alEnviar,
          decoration: InputDecoration(
            hintText: widget.pista,
            border: const OutlineInputBorder(),
            counterText: '',
            suffixIcon: widget.oculto
                ? IconButton(
                    tooltip: _escondido ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(_escondido ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _escondido = !_escondido),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
