import 'package:flutter/material.dart';
import '../utils/colores.dart';

/// Foto de perfil redonda; si no hay foto (o falla), muestra las iniciales.
class FotoPerfil extends StatelessWidget {
  final String? url;
  final String iniciales;
  final double tamano;

  const FotoPerfil({super.key, required this.url, required this.iniciales, this.tamano = 48});

  @override
  Widget build(BuildContext context) {
    final conIniciales = Container(
      width: tamano,
      height: tamano,
      color: context.verdeSuave,
      alignment: Alignment.center,
      child: Text(iniciales,
          style: TextStyle(
              fontSize: tamano * 0.36,
              fontWeight: FontWeight.w700,
              color: context.verdeFuerte)),
    );
    final direccion = url;
    return ClipOval(
      child: SizedBox(
        width: tamano,
        height: tamano,
        child: (direccion == null || direccion.isEmpty)
            ? conIniciales
            : Image.network(
                direccion,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => conIniciales,
                loadingBuilder: (context, hijo, progreso) =>
                    progreso == null ? hijo : conIniciales,
              ),
      ),
    );
  }
}
