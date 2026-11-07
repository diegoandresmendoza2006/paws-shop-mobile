import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/favorito_repository.dart';
import '../services/api_service.dart';
import 'aviso.dart';
import 'favoritos_event.dart';
import 'favoritos_state.dart';

/// Marca y desmarca favoritos. Primero cambia el corazón al instante y luego avisa al servidor;
/// si el servidor falla, devuelve el corazón a como estaba.
class FavoritosBloc extends Bloc<FavoritosEvent, FavoritosState> {
  final FavoritoRepository _repositorio;

  FavoritosBloc(this._repositorio) : super(const FavoritosState()) {
    on<FavoritosCargados>(_alCargar);
    on<MascotaAlternada>(_alAlternarMascota);
    on<ProductoAlternado>(_alAlternarProducto);
    on<FavoritosReiniciados>((e, emit) => emit(const FavoritosState()));
  }

  /// Copia del conjunto con el id agregado (si no estaba) o quitado (si estaba).
  Set<int> _alternado(Set<int> original, int id) {
    final copia = {...original};
    if (!copia.remove(id)) copia.add(id);
    return copia;
  }

  Future<void> _alCargar(FavoritosCargados e, Emitter<FavoritosState> emit) async {
    try {
      final mascotas = await _repositorio.idsDeMascotas();
      final productos = (await _repositorio.productos()).map((p) => p.id).toSet();
      emit(FavoritosState(mascotas: mascotas, productos: productos));
    } catch (_) {
      // Si falla, los corazones quedan vacíos; no es grave
    }
  }

  Future<void> _alAlternarMascota(MascotaAlternada e, Emitter<FavoritosState> emit) async {
    final eraFavorita = state.mascotas.contains(e.mascotaId);
    emit(FavoritosState(
        mascotas: _alternado(state.mascotas, e.mascotaId), productos: state.productos));
    try {
      if (eraFavorita) {
        await _repositorio.quitarMascota(e.mascotaId);
      } else {
        await _repositorio.marcarMascota(e.mascotaId);
      }
    } on ApiException catch (ex) {
      emit(FavoritosState(
          mascotas: _alternado(state.mascotas, e.mascotaId),
          productos: state.productos,
          aviso: Aviso(ex.mensaje, esError: true)));
    } catch (_) {
      emit(FavoritosState(
          mascotas: _alternado(state.mascotas, e.mascotaId),
          productos: state.productos,
          aviso: Aviso('No se pudo actualizar el favorito', esError: true)));
    }
  }

  Future<void> _alAlternarProducto(ProductoAlternado e, Emitter<FavoritosState> emit) async {
    final eraFavorito = state.productos.contains(e.productoId);
    emit(FavoritosState(
        mascotas: state.mascotas, productos: _alternado(state.productos, e.productoId)));
    try {
      if (eraFavorito) {
        await _repositorio.quitarProducto(e.productoId);
      } else {
        await _repositorio.marcarProducto(e.productoId);
      }
    } on ApiException catch (ex) {
      emit(FavoritosState(
          mascotas: state.mascotas,
          productos: _alternado(state.productos, e.productoId),
          aviso: Aviso(ex.mensaje, esError: true)));
    } catch (_) {
      emit(FavoritosState(
          mascotas: state.mascotas,
          productos: _alternado(state.productos, e.productoId),
          aviso: Aviso('No se pudo actualizar el favorito', esError: true)));
    }
  }
}
