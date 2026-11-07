import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/sesion.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../utils/formato.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Maneja la sesión: iniciar, registrar, cerrar y cambiar de rol.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repositorio;
  Sesion? _sesion;

  /// [restaurar] = true en la app real: arranca buscando una sesión guardada (sin mostrar el login un instante).
  AuthBloc(this._repositorio, {bool restaurar = false})
      : super(restaurar ? const AuthRestaurando() : const AuthInicial()) {
    on<SesionRestaurada>(_alRestaurar);
    on<SesionIniciada>(_alIniciarSesion);
    on<RegistroEnviado>(_alRegistrar);
    on<SesionCerrada>(_alCerrar);
    on<RolElegido>(_alElegirRol);
    on<CambioDeRolSolicitado>(_alPedirCambioDeRol);
    on<UsuarioActualizado>(_alActualizarUsuario);
  }

  Future<void> _alRestaurar(SesionRestaurada e, Emitter<AuthState> emit) async {
    final sesion = await _repositorio.restaurarSesion();
    if (sesion == null) {
      emit(const AuthInicial());
    } else {
      // El token guardado es de UNA cuenta: se entra directo con ella, sin preguntar el rol
      _sesion = sesion;
      emit(AuthAutenticado(sesion));
    }
  }

  /// Si tiene varias cuentas debe elegir; si no, entra directo.
  void _terminarEntrada(Sesion sesion, Emitter<AuthState> emit) {
    _sesion = sesion;
    emit(sesion.tieneVariosRoles ? AuthElegirRol(sesion) : AuthAutenticado(sesion));
  }

  Future<void> _alIniciarSesion(SesionIniciada e, Emitter<AuthState> emit) async {
    emit(const AuthCargando());
    try {
      _terminarEntrada(await _repositorio.iniciarSesion(e.email, e.password), emit);
    } on ApiException catch (ex) {
      emit(AuthError(ex.mensaje));
    } catch (_) {
      emit(const AuthError('Ocurrió un error inesperado.'));
    }
  }

  Future<void> _alRegistrar(RegistroEnviado e, Emitter<AuthState> emit) async {
    emit(const AuthCargando());
    try {
      final sesion = await _repositorio.registrar(
        nombreCompleto: e.nombreCompleto,
        email: e.email,
        password: e.password,
        tipoDocumento: e.tipoDocumento,
        numeroDocumento: e.numeroDocumento,
        fechaNacimiento: fechaParaApi(e.fechaNacimiento),
        telefono: e.telefono,
        direccion: e.direccion,
      );
      _terminarEntrada(sesion, emit);
    } on ApiException catch (ex) {
      emit(AuthError(ex.mensaje));
    } catch (_) {
      emit(const AuthError('Ocurrió un error inesperado.'));
    }
  }

  void _alCerrar(SesionCerrada e, Emitter<AuthState> emit) {
    _repositorio.cerrarSesion();
    _sesion = null;
    emit(const AuthInicial());
  }

  Future<void> _alElegirRol(RolElegido e, Emitter<AuthState> emit) async {
    final actual = _sesion;
    if (actual == null) return;
    // Eligió la cuenta con la que ya está dentro: no hace falta ir al servidor
    if (e.usuarioId == actual.usuario.id) {
      emit(AuthAutenticado(actual));
      return;
    }
    emit(const AuthCargando(conSesion: true));
    try {
      final nueva = await _repositorio.cambiarRol(e.usuarioId);
      _sesion = nueva;
      emit(AuthAutenticado(nueva));
    } on ApiException catch (ex) {
      emit(AuthElegirRol(actual, mensaje: ex.mensaje));
    } catch (_) {
      emit(AuthElegirRol(actual, mensaje: 'Ocurrió un error inesperado.'));
    }
  }

  void _alPedirCambioDeRol(CambioDeRolSolicitado e, Emitter<AuthState> emit) {
    final actual = _sesion;
    if (actual != null) emit(AuthElegirRol(actual));
  }

  void _alActualizarUsuario(UsuarioActualizado e, Emitter<AuthState> emit) {
    final actual = _sesion;
    if (actual == null) return;
    final nueva = actual.conUsuario(e.usuario);
    _sesion = nueva;
    emit(AuthAutenticado(nueva));
  }
}
