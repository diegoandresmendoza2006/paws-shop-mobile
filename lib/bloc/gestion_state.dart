import 'gestion_event.dart';

/// Cómo va la acción que pidió el personal.
sealed class GestionState {
  const GestionState();
}

class GestionInicial extends GestionState {
  const GestionInicial();
}

class GestionEnCurso extends GestionState {
  const GestionEnCurso();
}

class GestionExitosa extends GestionState {
  final String mensaje;
  const GestionExitosa(this.mensaje);
}

/// La cuenta tiene historial (adopciones o compras): hay que preguntar si se elimina todo de todos modos.
/// [eventoForzado] es la misma acción pero borrando también el historial: se envía solo si el admin acepta.
class GestionConflicto extends GestionState {
  final String mensaje;
  final GestionEvent eventoForzado;
  const GestionConflicto(this.mensaje, this.eventoForzado);
}

class GestionError extends GestionState {
  final String mensaje;
  const GestionError(this.mensaje);
}
