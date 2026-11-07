import '../models/mes_historial.dart';
import '../models/metricas.dart';

/// Lo que el PanelBloc le RESPONDE al panel.
sealed class PanelState {
  const PanelState();
}

class PanelInicial extends PanelState {
  const PanelInicial();
}

class PanelCargando extends PanelState {
  const PanelCargando();
}

class PanelCargado extends PanelState {
  /// Los números del mes elegido (o del mes actual cuando se mira todo el historial).
  final Metricas metricas;

  /// Todos los meses desde el primer movimiento hasta hoy, del más antiguo al más reciente.
  final List<MesHistorial> historial;

  /// '2026-11' o 'todo'.
  final String periodo;

  /// Está trayendo los números de otro mes: se siguen viendo los anteriores con una barrita.
  final bool cambiandoPeriodo;

  const PanelCargado({
    required this.metricas,
    required this.historial,
    required this.periodo,
    this.cambiandoPeriodo = false,
  });

  bool get esHistorico => periodo == 'todo';

  String get titulo {
    if (esHistorico) return 'Todo el historial';
    for (final m in historial) {
      if (m.mes == periodo) return m.nombre;
    }
    return periodo;
  }

  // Cifras del periodo elegido: de un mes, o la suma de todos los meses.
  int get solicitudes => esHistorico ? _suma((m) => m.solicitudes) : metricas.solicitudesMes;
  int get adopciones => esHistorico ? _suma((m) => m.adopciones) : metricas.adopcionesMes;
  int get pedidos => esHistorico ? _suma((m) => m.pedidos) : metricas.pedidosMes;
  int get usuariosNuevos => esHistorico ? _suma((m) => m.usuariosNuevos) : metricas.usuariosNuevosMes;
  double get ventas =>
      esHistorico ? historial.fold<double>(0, (a, m) => a + m.ventas) : metricas.ventasMes;

  int _suma(int Function(MesHistorial) valor) => historial.fold<int>(0, (a, m) => a + valor(m));

  PanelCargado copiarCon({Metricas? metricas, String? periodo, bool? cambiandoPeriodo}) => PanelCargado(
        metricas: metricas ?? this.metricas,
        historial: historial,
        periodo: periodo ?? this.periodo,
        cambiandoPeriodo: cambiandoPeriodo ?? this.cambiandoPeriodo,
      );
}

class PanelError extends PanelState {
  final String mensaje;
  const PanelError(this.mensaje);
}
