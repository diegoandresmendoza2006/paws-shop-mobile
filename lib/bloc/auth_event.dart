import '../models/usuario.dart';

/// Lo que la pantalla le PIDE al AuthBloc.
sealed class AuthEvent {
  const AuthEvent();
}

/// "Inicia sesión con este correo y contraseña".
class SesionIniciada extends AuthEvent {
  final String email;
  final String password;
  const SesionIniciada({required this.email, required this.password});
}

/// "Crea mi cuenta" (con documento, fecha de nacimiento, teléfono y dirección) y entra.
class RegistroEnviado extends AuthEvent {
  final String nombreCompleto;
  final String email;
  final String password;
  final String tipoDocumento;
  final String numeroDocumento;
  final DateTime fechaNacimiento;
  final String telefono;
  final String direccion;

  const RegistroEnviado({
    required this.nombreCompleto,
    required this.email,
    required this.password,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.fechaNacimiento,
    required this.telefono,
    required this.direccion,
  });
}

/// "Cierra mi sesión".
class SesionCerrada extends AuthEvent {
  const SesionCerrada();
}

/// El usuario con dos cuentas eligió con cuál quiere entrar.
class RolElegido extends AuthEvent {
  final int usuarioId;
  const RolElegido(this.usuarioId);
}

/// "Quiero cambiar de rol" (desde el menú, ya con la sesión abierta).
class CambioDeRolSolicitado extends AuthEvent {
  const CambioDeRolSolicitado();
}

/// El usuario editó su perfil: refresca los datos guardados en la sesión.
class UsuarioActualizado extends AuthEvent {
  final Usuario usuario;
  const UsuarioActualizado(this.usuario);
}

/// La app acaba de abrirse: si quedó una sesión guardada, se recupera sin pedir la contraseña.
class SesionRestaurada extends AuthEvent {
  const SesionRestaurada();
}
