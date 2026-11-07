import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../services/api_service.dart';
import 'catalogos_event.dart';
import 'catalogos_state.dart';

/// Carga los refugios y las categorías una sola vez, para los formularios y los filtros.
class CatalogosBloc extends Bloc<CatalogosEvent, CatalogosState> {
  final RefugioRepository _refugios;
  final ProductoRepository _productos;

  CatalogosBloc(this._refugios, this._productos) : super(const CatalogosCargando()) {
    on<CatalogosSolicitados>(_alSolicitar);
  }

  Future<void> _alSolicitar(CatalogosSolicitados evento, Emitter<CatalogosState> emit) async {
    emit(const CatalogosCargando());
    try {
      final refugios = await _refugios.listar();
      final categorias = await _productos.categorias();
      emit(CatalogosCargados(refugios: refugios, categorias: categorias));
    } on ApiException catch (e) {
      emit(CatalogosError(e.mensaje));
    } catch (_) {
      emit(const CatalogosError('No se pudieron cargar los datos del formulario.'));
    }
  }
}
