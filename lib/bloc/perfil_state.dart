import '../models/usuario.dart';

/// Lo que el PerfilBloc le RESPONDE a la pantalla.
sealed class PerfilState {
  const PerfilState();
}

class PerfilInicial extends PerfilState {
  const PerfilInicial();
}

class PerfilGuardando extends PerfilState {
  const PerfilGuardando();
}

/// Todo salió bien. [usuario] viene con los datos nuevos (null si solo cambió la contraseña).
class PerfilActualizado extends PerfilState {
  final Usuario? usuario;
  final String mensaje;
  const PerfilActualizado({this.usuario, required this.mensaje});
}

class PerfilError extends PerfilState {
  final String mensaje;
  const PerfilError(this.mensaje);
}
