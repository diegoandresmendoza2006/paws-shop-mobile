import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el dispositivo el token de la sesión para que, al volver a abrir la app,
/// no haya que escribir de nuevo el correo y la contraseña.
class SesionLocalRepository {
  static const _clave = 'token_sesion';

  Future<String?> leerToken() async {
    try {
      return (await SharedPreferences.getInstance()).getString(_clave);
    } catch (_) {
      return null; // si no se puede leer, simplemente se pide iniciar sesión
    }
  }

  Future<void> guardarToken(String token) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_clave, token);
    } catch (_) {
      // no es grave: la sesión funciona igual hasta cerrar la app
    }
  }

  Future<void> borrar() async {
    try {
      await (await SharedPreferences.getInstance()).remove(_clave);
    } catch (_) {}
  }
}
