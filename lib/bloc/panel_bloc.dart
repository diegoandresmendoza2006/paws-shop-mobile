import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/admin_repository.dart';
import '../services/api_service.dart';
import 'panel_event.dart';
import 'panel_state.dart';

/// Carga los números del administrador: el mes que elija o todo el historial, mes a mes.
class PanelBloc extends Bloc<PanelEvent, PanelState> {
  /// Valor de [PanelPeriodoElegido] para ver todos los meses juntos.
  static const String todoElHistorial = 'todo';

  final AdminRepository _repositorio;
  String? _periodo; // null = el mes actual (el último del historial)

  PanelBloc(this._repositorio) : super(const PanelInicial()) {
    on<PanelSolicitado>(_alSolicitar);
    on<PanelPeriodoElegido>(_alElegirPeriodo);
  }

  Future<void> _alSolicitar(PanelSolicitado e, Emitter<PanelState> emit) async {
    if (!e.silencioso) emit(const PanelCargando());
    try {
      final historial = await _repositorio.historial();
      // El historial siempre trae el mes actual al final
      final periodo = _periodo ?? (historial.isEmpty ? null : historial.last.mes);
      final delMes = periodo == null || periodo == todoElHistorial ? null : periodo;
      final metricas = await _repositorio.metricas(mes: delMes);
      _periodo = periodo ?? metricas.mes;
      emit(PanelCargado(metricas: metricas, historial: historial, periodo: _periodo!));
    } on ApiException catch (ex) {
      emit(PanelError(ex.mensaje));
    } catch (_) {
      emit(const PanelError('Ocurrió un error inesperado.'));
    }
  }

  Future<void> _alElegirPeriodo(PanelPeriodoElegido e, Emitter<PanelState> emit) async {
    final actual = state;
    if (actual is! PanelCargado || e.periodo == actual.periodo) return;
    _periodo = e.periodo;
    if (e.periodo == todoElHistorial) {
      // Las cifras salen de sumar los meses que ya tenemos: no hace falta pedir nada
      emit(actual.copiarCon(periodo: e.periodo, cambiandoPeriodo: false));
      return;
    }
    emit(actual.copiarCon(periodo: e.periodo, cambiandoPeriodo: true));
    try {
      final metricas = await _repositorio.metricas(mes: e.periodo);
      if (_periodo != e.periodo) return; // eligió otro mientras tanto
      emit(actual.copiarCon(metricas: metricas, periodo: e.periodo, cambiandoPeriodo: false));
    } on ApiException catch (ex) {
      emit(PanelError(ex.mensaje));
    } catch (_) {
      emit(const PanelError('Ocurrió un error inesperado.'));
    }
  }
}
