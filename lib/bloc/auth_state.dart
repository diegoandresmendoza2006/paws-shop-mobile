import '../models/sesion.dart';

/// Lo que el AuthBloc le RESPONDE a la pantalla.
sealed class AuthState {
  const AuthState();
}

/// No hay sesión (se ve el login).
class AuthInicial extends AuthState {
  const AuthInicial();
}

/// La app acaba de abrirse y está buscando una sesión guardada (se ve una pantalla de carga).
class AuthRestaurando extends AuthState {
  const AuthRestaurando();
}

/// Esperando al servidor. [conSesion] = true cuando ya había una sesión (cambio de rol).
class AuthCargando extends AuthState {
  final bool conSesion;
  const AuthCargando({this.conSesion = false});
}

/// Sesión abierta: se ve la pantalla principal según el rol.
class AuthAutenticado extends AuthState {
  final Sesion sesion;
  const AuthAutenticado(this.sesion);
}

/// La persona tiene más de una cuenta: debe elegir cómo quiere entrar.
class AuthElegirRol extends AuthState {
  final Sesion sesion;
  final String? mensaje;
  const AuthElegirRol(this.sesion, {this.mensaje});
}

/// Algo falló (correo repetido, contraseña incorrecta, sin internet...).
class AuthError extends AuthState {
  final String mensaje;
  const AuthError(this.mensaje);
}
