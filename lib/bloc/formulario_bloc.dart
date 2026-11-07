import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/foto_nueva.dart';
import '../repositories/admin_repository.dart';
import '../repositories/imagen_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/seguimiento_repository.dart';
import '../services/api_service.dart';
import 'formulario_event.dart';
import 'formulario_state.dart';

/// Guarda los formularios de mascotas, productos, refugios y encargados.
/// Si el formulario trae una foto nueva, la sube primero y luego guarda con la dirección de la foto.
// ignore_for_file: prefer_initializing_formals
class FormularioBloc extends Bloc<FormularioEvent, FormularioState> {
  final MascotaRepository _mascotas;
  final ProductoRepository _productos;
  final RefugioRepository _refugios;
  final AdminRepository _admin;
  final ImagenRepository _imagenes;
  final SeguimientoRepository _seguimientos;

  /// Arma el BLoC con los repositorios que ya están en el árbol de la app (main.dart).
  factory FormularioBloc.desdeContexto(BuildContext context) => FormularioBloc(
        mascotas: context.read<MascotaRepository>(),
        productos: context.read<ProductoRepository>(),
        refugios: context.read<RefugioRepository>(),
        admin: context.read<AdminRepository>(),
        imagenes: context.read<ImagenRepository>(),
        seguimientos: context.read<SeguimientoRepository>(),
      );

  FormularioBloc({
    required MascotaRepository mascotas,
    required ProductoRepository productos,
    required RefugioRepository refugios,
    required AdminRepository admin,
    required ImagenRepository imagenes,
    required SeguimientoRepository seguimientos,
  })  : _mascotas = mascotas,
        _productos = productos,
        _refugios = refugios,
        _admin = admin,
        _imagenes = imagenes,
        _seguimientos = seguimientos,
        super(const FormularioInicial()) {
    on<MascotaGuardada>((e, emit) => _guardar(
          emit,
          mensaje: e.id == null ? 'Mascota creada' : 'Cambios guardados',
          foto: e.foto,
          tipoFoto: 'mascotas',
          subcarpeta: (e.datos['raza'] ?? '').toString(),
          especie: (e.datos['especie'] ?? '').toString(),
          datos: e.datos,
          accion: (datos) => e.id == null ? _mascotas.crear(datos) : _mascotas.editar(e.id!, datos),
        ));
    on<ProductoGuardado>((e, emit) => _guardar(
          emit,
          mensaje: e.id == null ? 'Producto creado' : 'Cambios guardados',
          foto: e.foto,
          tipoFoto: 'productos',
          subcarpeta: e.categoriaNombre,
          datos: e.datos,
          accion: (datos) => e.id == null ? _productos.crear(datos) : _productos.editar(e.id!, datos),
        ));
    on<RefugioGuardado>((e, emit) => _guardar(
          emit,
          mensaje: e.id == null ? 'Refugio creado' : 'Cambios guardados',
          datos: e.datos,
          accion: (datos) => e.id == null ? _refugios.crear(datos) : _refugios.editar(e.id!, datos),
        ));
    on<EncargadoGuardado>((e, emit) => _guardar(
          emit,
          mensaje: e.id == null ? 'Encargado creado' : 'Cambios guardados',
          datos: e.datos,
          accion: (datos) => e.id == null ? _admin.crearEncargado(datos) : _admin.editarEncargado(e.id!, datos),
        ));
    on<SeguimientoEnviado>((e, emit) => _guardar(
          emit,
          mensaje: 'Reporte enviado. ¡Gracias por contarnos cómo está!',
          datos: const {},
          accion: (_) => _seguimientos.enviar(
              solicitudId: e.solicitudId, estadoSalud: e.estadoSalud, observaciones: e.observaciones),
        ));
  }

  Future<void> _guardar(
    Emitter<FormularioState> emit, {
    required String mensaje,
    required Map<String, dynamic> datos,
    required Future<Object?> Function(Map<String, dynamic> datos) accion,
    FotoNueva? foto,
    String tipoFoto = '',
    String subcarpeta = '',
    String especie = '',
  }) async {
    emit(const FormularioGuardando());
    String? fotoSubida;
    try {
      final completos = Map<String, dynamic>.of(datos);
      if (foto != null) {
        fotoSubida = await _imagenes.subir(foto, tipo: tipoFoto, subcarpeta: subcarpeta, especie: especie);
        completos['imagen_url'] = fotoSubida;
      }
      await accion(completos);
      emit(FormularioExitoso(mensaje));
    } on ApiException catch (ex) {
      await _descartar(fotoSubida);
      emit(FormularioError(ex.mensaje));
    } catch (_) {
      await _descartar(fotoSubida);
      emit(const FormularioError('Ocurrió un error inesperado.'));
    }
  }

  /// Si la foto se subió pero el guardado falló, se borra para no dejar fotos sueltas.
  Future<void> _descartar(String? url) async {
    if (url == null) return;
    try {
      await _imagenes.descartar(url);
    } catch (_) {
      // no es grave: la foto sobrante no afecta a nadie
    }
  }
}
