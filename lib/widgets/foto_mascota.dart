import 'package:flutter/material.dart';

import '../utils/colores.dart';

/// Foto de la mascota; si no tiene o falla la carga, muestra un icono.
class FotoMascota extends StatelessWidget {
  final String? url;
  const FotoMascota({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final vacio = ColoredBox(
      color: context.verdeSuave,
      child: const Center(child: Icon(Icons.pets, size: 40, color: Color(0xFF28A745))),
    );
    if (url == null || url!.isEmpty) return vacio;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => vacio,
      loadingBuilder: (context, hijo, progreso) =>
          progreso == null ? hijo : vacio,
    );
  }
}
