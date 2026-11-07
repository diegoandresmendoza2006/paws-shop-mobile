/// Lo que el panel del administrador le PIDE al PanelBloc.
sealed class PanelEvent {
  const PanelEvent();
}

/// Carga (o recarga) el panel. Conserva el mes que se estaba viendo.
class PanelSolicitado extends PanelEvent {
  final bool silencioso;
  const PanelSolicitado({this.silencioso = false});
}

/// Elige qué mirar: un mes ('2026-11') o todo el historial ([PanelBloc.todoElHistorial]).
class PanelPeriodoElegido extends PanelEvent {
  final String periodo;
  const PanelPeriodoElegido(this.periodo);
}
