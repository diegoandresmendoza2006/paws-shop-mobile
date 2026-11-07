/// Lo que la pantalla "Mi perfil" le PIDE al PerfilBloc.
sealed class PerfilEvent {
  const PerfilEvent();
}

/// Guardar los datos personales (solo los campos que cambiaron o se llenaron).
class PerfilGuardado extends PerfilEvent {
  final Map<String, dynamic> datos;
  const PerfilGuardado(this.datos);
}

/// El usuario eligió una foto de su galería.
class FotoElegida extends PerfilEvent {
  final List<int> bytes;
  final String nombre;
  const FotoElegida(this.bytes, this.nombre);
}

/// Quitar la foto de perfil.
class FotoQuitada extends PerfilEvent {
  const FotoQuitada();
}

/// Cambiar la contraseña.
class PasswordCambiada extends PerfilEvent {
  final String actual;
  final String nueva;
  const PasswordCambiada({required this.actual, required this.nueva});
}
