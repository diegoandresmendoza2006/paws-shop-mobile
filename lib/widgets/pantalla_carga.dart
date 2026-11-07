import 'dart:async';

import 'package:flutter/material.dart';

import 'logo_paws.dart';
import '../utils/colores.dart';

/// Lo que se ve mientras algo carga: el logo y un circulito (nunca una pantalla en blanco).
/// Si tarda más de 6 segundos explica que el servidor gratis puede estar despertando.
class PantallaCarga extends StatefulWidget {
  final String? mensaje;
  final bool compacta; // true dentro de una lista: logo pequeño y sin fondo

  const PantallaCarga({super.key, this.mensaje, this.compacta = false});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  Timer? _temporizador;
  bool _tardando = false;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _tardando = true);
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = _tardando
        ? 'El servidor estaba dormido y está despertando.\nPuede tardar hasta 30 segundos…'
        : widget.mensaje;
    final contenido = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoPaws(tamano: widget.compacta ? 56 : 96),
        const SizedBox(height: 14),
        if (!widget.compacta)
          Text('Paws&Shop',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: context.verdeFuerte)),
        if (!widget.compacta) const SizedBox(height: 14),
        const SizedBox(
            width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3)),
        if (texto != null) ...[
          const SizedBox(height: 14),
          Text(texto, textAlign: TextAlign.center),
        ],
      ],
    );
    return Container(
      color: widget.compacta ? null : Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      height: widget.compacta ? null : double.infinity,
      padding: const EdgeInsets.all(24),
      child: Center(child: contenido),
    );
  }
}
