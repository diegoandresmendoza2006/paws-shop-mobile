import 'package:flutter/material.dart';

/// El logo de la app: una huella blanca sobre un círculo verde.
class LogoPaws extends StatelessWidget {
  final double tamano;
  const LogoPaws({super.key, this.tamano = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: const BoxDecoration(color: Color(0xFF28A745), shape: BoxShape.circle),
      child: Icon(Icons.pets, color: Colors.white, size: tamano * 0.55),
    );
  }
}
