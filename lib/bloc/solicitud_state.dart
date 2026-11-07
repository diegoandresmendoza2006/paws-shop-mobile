/// Lo que el SolicitudBloc le RESPONDE al formulario.
sealed class SolicitudState {
  const SolicitudState();
}

class SolicitudInicial extends SolicitudState {
  const SolicitudInicial();
}

class SolicitudEnviando extends SolicitudState {
  const SolicitudEnviando();
}

class SolicitudExitosa extends SolicitudState {
  const SolicitudExitosa();
}

class SolicitudError extends SolicitudState {
  final String mensaje;
  const SolicitudError(this.mensaje);
}
