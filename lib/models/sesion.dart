import 'cuenta.dart';
import 'usuario.dart';

/// Lo que se guarda al iniciar sesión: el token, el usuario y todas sus cuentas (roles).
class Sesion {
  final String token;
  final Usuario usuario;
  final List<Cuenta> cuentas;

  const Sesion({required this.token, required this.usuario, this.cuentas = const []});

  /// ¿Esta persona tiene más de un rol? Entonces la app le pregunta cómo quiere entrar.
  bool get tieneVariosRoles => cuentas.length > 1;

  Sesion conUsuario(Usuario nuevo) =>
      Sesion(token: token, usuario: nuevo, cuentas: cuentas);
}
