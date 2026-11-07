import 'dart:async';

import 'package:flutter/material.dart';

/// Caja de búsqueda: espera 0,45 s después de la última tecla para consultar (así no se
/// pide al servidor con cada letra) y tiene una "x" para borrar.
class BarraBusqueda extends StatefulWidget {
  final String pista;
  final ValueChanged<String> alBuscar;

  const BarraBusqueda({super.key, required this.pista, required this.alBuscar});

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  final TextEditingController _controlador = TextEditingController();
  Timer? _espera;

  @override
  void dispose() {
    _espera?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  void _alEscribir(String texto) {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 450), () => widget.alBuscar(texto.trim()));
    setState(() {}); // para mostrar u ocultar la "x"
  }

  void _borrar() {
    _espera?.cancel();
    _controlador.clear();
    widget.alBuscar('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _controlador,
        onChanged: _alEscribir,
        textInputAction: TextInputAction.search,
        onSubmitted: (texto) {
          _espera?.cancel();
          widget.alBuscar(texto.trim());
        },
        decoration: InputDecoration(
          hintText: widget.pista,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controlador.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Borrar búsqueda',
                  icon: const Icon(Icons.close),
                  onPressed: _borrar,
                ),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
          isDense: true,
        ),
      ),
    );
  }
}
