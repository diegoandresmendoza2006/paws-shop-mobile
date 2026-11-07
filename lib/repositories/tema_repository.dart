import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el teléfono el modo (claro, oscuro o del sistema) que eligió CADA persona.
/// Se identifica por el correo: si tiene dos cuentas (encargado y usuario) usa el mismo modo.
class TemaRepository {
  static const _prefijo = 'modo_tema_';

  String _clave(String email) => '$_prefijo${email.trim().toLowerCase()}';

  /// El modo guardado de esa persona; si nunca eligió uno, claro.
  Future<ThemeMode> leer(String email) async {
    try {
      final guardado = (await SharedPreferences.getInstance()).getString(_clave(email));
      return ThemeMode.values.firstWhere((m) => m.name == guardado, orElse: () => ThemeMode.light);
    } catch (_) {
      return ThemeMode.light;
    }
  }

  Future<void> guardar(String email, ThemeMode modo) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_clave(email), modo.name);
    } catch (_) {
      // no es grave: el modo sigue aplicado hasta cerrar la sesión
    }
  }
}
