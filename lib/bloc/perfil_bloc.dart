import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/perfil_repository.dart';
import '../services/api_service.dart';
import 'perfil_event.dart';
import 'perfil_state.dart';

/// Edita los datos del usuario, su contraseña y su foto de perfil.
class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final PerfilRepository _repositorio;

  PerfilBloc(this._repositorio) : super(const PerfilInicial()) {
    on<PerfilGuardado>(_alGuardar);
    on<FotoElegida>(_alElegirFoto);
    on<FotoQuitada>(_alQuitarFoto);
    on<PasswordCambiada>(_alCambiarPassword);
  }

  Future<void> _alGuardar(PerfilGuardado e, Emitter<PerfilState> emit) async {
    emit(const PerfilGuardando());
    try {
      final usuario = await _repositorio.actualizar(e.datos);
      emit(PerfilActualizado(usuario: usuario, mensaje: 'Datos guardados'));
    } on ApiException catch (ex) {
      emit(PerfilError(ex.mensaje));
    } catch (_) {
      emit(const PerfilError('Ocurrió un error inesperado.'));
    }
  }

  Future<void> _alElegirFoto(FotoElegida e, Emitter<PerfilState> emit) async {
    emit(const PerfilGuardando());
    try {
      final usuario = await _repositorio.subirFoto(e.bytes, e.nombre);
      emit(PerfilActualizado(usuario: usuario, mensaje: 'Foto actualizada'));
    } on ApiException catch (ex) {
      emit(PerfilError(ex.mensaje));
    } catch (_) {
      emit(const PerfilError('Ocurrió un error inesperado.'));
    }
  }

  Future<void> _alQuitarFoto(FotoQuitada e, Emitter<PerfilState> emit) async {
    emit(const PerfilGuardando());
    try {
      final usuario = await _repositorio.quitarFoto();
      emit(PerfilActualizado(usuario: usuario, mensaje: 'Foto eliminada'));
    } on ApiException catch (ex) {
      emit(PerfilError(ex.mensaje));
    } catch (_) {
      emit(const PerfilError('Ocurrió un error inesperado.'));
    }
  }

  Future<void> _alCambiarPassword(PasswordCambiada e, Emitter<PerfilState> emit) async {
    emit(const PerfilGuardando());
    try {
      await _repositorio.cambiarPassword(e.actual, e.nueva);
      emit(const PerfilActualizado(mensaje: 'Contraseña cambiada'));
    } on ApiException catch (ex) {
      emit(PerfilError(ex.mensaje));
    } catch (_) {
      emit(const PerfilError('Ocurrió un error inesperado.'));
    }
  }
}
