import '../models/solicitud_adopcion.dart';

/// Lo que el formulario de adopción le PIDE al SolicitudBloc.
sealed class SolicitudEvent {
  const SolicitudEvent();
}

class SolicitudEnviada extends SolicitudEvent {
  final SolicitudAdopcionNueva solicitud;
  const SolicitudEnviada(this.solicitud);
}
