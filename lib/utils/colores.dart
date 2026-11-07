import 'package:flutter/material.dart';

/// Colores de la marca que cambian solos entre modo claro y modo oscuro
/// (así los textos verdes y rojos se siguen leyendo sobre el fondo oscuro).
extension ColoresDeTema on BuildContext {
  bool get esOscuro => Theme.of(this).brightness == Brightness.dark;

  /// Verde fuerte para textos e iconos de acento.
  Color get verdeFuerte => esOscuro ? const Color(0xFF81C784) : const Color(0xFF1B5E20);

  /// Verde muy suave para fondos de etiquetas y avatares.
  Color get verdeSuave => esOscuro ? const Color(0xFF1E3A22) : const Color(0xFFE8F5E9);

  /// Rojo para errores y acciones peligrosas.
  Color get rojoFuerte => esOscuro ? const Color(0xFFEF9A9A) : const Color(0xFFB71C1C);

  /// Fondo suave de los avisos de error.
  Color get rojoSuave => esOscuro ? const Color(0xFF3F2220) : const Color(0xFFFDECEA);

  /// Gris de los textos de ayuda.
  Color get textoSecundario => Theme.of(this).colorScheme.onSurfaceVariant;
}
