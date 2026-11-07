import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/solicitud_repository.dart';
import '../services/api_service.dart';
import 'solicitud_event.dart';
import 'solicitud_state.dart';

/// Envía el formulario de adopción.
class SolicitudBloc extends Bloc<SolicitudEvent, SolicitudState> {
  final SolicitudRepository _repositorio;

  SolicitudBloc(this._repositorio) : super(const SolicitudInicial()) {
    on<SolicitudEnviada>(_alEnviar);
  }

  Future<void> _alEnviar(SolicitudEnviada e, Emitter<SolicitudState> emit) async {
    emit(const SolicitudEnviando());
    try {
      await _repositorio.enviar(e.solicitud);
      emit(const SolicitudExitosa());
    } on ApiException catch (ex) {
      emit(SolicitudError(ex.mensaje));
    } catch (_) {
      emit(const SolicitudError('Ocurrió un error inesperado.'));
    }
  }
}
