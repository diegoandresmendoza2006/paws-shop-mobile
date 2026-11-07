import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/admin_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../services/api_service.dart';
import 'gestion_event.dart';
import 'gestion_state.dart';

/// Ejecuta las acciones de gestión: editar/eliminar clientes, resolver solicitudes,
/// cambiar el estado o eliminar mascotas, productos y refugios. La pantalla solo pide y escucha el resultado.
// ignore_for_file: prefer_initializing_formals

class GestionBloc extends Bloc<GestionEvent, GestionState> {
  final AdminRepository _admin;
  final SolicitudRepository _solicitudes;
  final MascotaRepository _mascotas;
  final ProductoRepository _productos;
  final RefugioRepository _refugios;

  GestionBloc({
    required AdminRepository admin,
    required SolicitudRepository solicitudes,
    required MascotaRepository mascotas,
    required ProductoRepository productos,
    required RefugioRepository refugios,
  })  : _admin = admin,
        _solicitudes = solicitudes,
        _mascotas = mascotas,
        _productos = productos,
        _refugios = refugios,
        super(const GestionInicial()) {
    on<ClienteEditado>((e, emit) => _ejecutar(emit, 'Cliente actualizado', () => _admin.editarCliente(e.id, e.datos)));
    on<ClienteEliminado>((e, emit) => _ejecutar(
        emit, 'Cliente eliminado', () => _admin.eliminarCliente(e.id, forzar: e.forzar),
        reintentoForzado: e.forzar ? null : ClienteEliminado(e.id, forzar: true)));
    on<SolicitudResuelta>((e, emit) => _ejecutar(
        emit,
        e.estado == 'Aprobada' ? 'Solicitud aprobada' : 'Solicitud rechazada',
        () => _solicitudes.resolver(e.id, e.estado, e.comentario)));
    on<MascotaEstadoCambiado>((e, emit) =>
        _ejecutar(emit, 'Estado cambiado a "${e.estado}"', () => _mascotas.cambiarEstado(e.id, e.estado)));
    on<MascotaEliminada>((e, emit) =>
        _ejecutar(emit, 'Mascota eliminada', () => _mascotas.eliminar(e.id, forzar: e.forzar)));
    on<ProductoEliminado>((e, emit) =>
        _ejecutar(emit, 'Producto eliminado', () => _productos.eliminar(e.id)));
    on<EncargadoEliminado>((e, emit) => _ejecutar(
        emit, 'Encargado eliminado', () => _admin.eliminarEncargado(e.id, forzar: e.forzar),
        reintentoForzado: e.forzar ? null : EncargadoEliminado(e.id, forzar: true)));
    on<RefugioEliminado>((e, emit) =>
        _ejecutar(emit, 'Refugio eliminado', () => _refugios.eliminar(e.id)));
  }

  Future<void> _ejecutar(
    Emitter<GestionState> emit,
    String mensajeExito,
    Future<void> Function() accion, {
    GestionEvent? reintentoForzado,
  }) async {
    emit(const GestionEnCurso());
    try {
      await accion();
      emit(GestionExitosa(mensajeExito));
    } on ApiException catch (ex) {
      // 409 al eliminar una cuenta con historial: la pantalla pregunta si se borra todo
      emit(ex.codigo == 409 && reintentoForzado != null
          ? GestionConflicto(ex.mensaje, reintentoForzado)
          : GestionError(ex.mensaje));
    } catch (_) {
      emit(const GestionError('Ocurrió un error inesperado.'));
    }
  }
}
