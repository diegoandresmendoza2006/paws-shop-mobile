import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/pagina.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';
import 'lista_event.dart';
import 'lista_state.dart';

/// Función que sabe pedir UNA página: `(número de página, texto de búsqueda, filtros) -> Pagina<T>`.
typedef CargadorPagina<T> = Future<Pagina<T>> Function(
    int pagina, String busqueda, Map<String, String> filtros);

/// Un solo BLoC para TODAS las listas de la app (mascotas, productos, clientes, auditoría...).
/// Cada pantalla le pasa su propio [CargadorPagina]: así no repetimos la lógica de
/// "cargar, cambiar de página, buscar y reintentar". Muestra UNA página a la vez.
class ListaBloc<T> extends Bloc<ListaEvent, ListaState<T>> {
  final CargadorPagina<T> _cargar;
  final int porPagina;
  int _paginaActual = 1;
  String _busqueda = '';
  Map<String, String> _filtros;
  int _version = 0; // sube con cada carga: así se ignoran respuestas viejas

  ListaBloc(this._cargar, {Map<String, String> filtros = const {}, this.porPagina = ApiConfig.porPagina})
      : _filtros = Map<String, String>.of(filtros),
        super(ListaInicial<T>()) {
    on<ListaIniciada>(_alIniciar);
    on<ListaPaginaSolicitada>(_alCambiarPagina);
    on<ListaFiltrada>(_alFiltrar);
  }

  Future<void> _alIniciar(ListaIniciada evento, Emitter<ListaState<T>> emit) {
    // Silenciosa = recargar la misma página; normal = empezar de nuevo desde la 1
    return _cargarPagina(evento.silenciosa ? _paginaActual : 1, emit, conservarVista: evento.silenciosa);
  }

  Future<void> _alCambiarPagina(ListaPaginaSolicitada evento, Emitter<ListaState<T>> emit) {
    final actual = state;
    if (actual is! ListaCargada<T>) return Future.value();
    if (evento.pagina < 1 || evento.pagina > actual.totalPaginas || evento.pagina == actual.pagina) {
      return Future.value();
    }
    return _cargarPagina(evento.pagina, emit, conservarVista: true);
  }

  Future<void> _alFiltrar(ListaFiltrada evento, Emitter<ListaState<T>> emit) {
    if (evento.busqueda != null) _busqueda = evento.busqueda!;
    if (evento.filtros != null) _filtros = Map<String, String>.of(evento.filtros!);
    return _cargarPagina(1, emit, conservarVista: true);
  }

  /// Pide la página [pagina]. Con [conservarVista] se sigue viendo lo anterior mientras llega.
  Future<void> _cargarPagina(int pagina, Emitter<ListaState<T>> emit, {required bool conservarVista}) async {
    final version = ++_version;
    final actual = state;
    final ListaCargada<T>? vista = (conservarVista && actual is ListaCargada<T>) ? actual : null;
    if (vista != null) {
      emit(vista.copiarCon(cargandoPagina: true, limpiarError: true));
    } else {
      emit(ListaCargando<T>());
    }
    try {
      var numero = pagina;
      var resultado = await _cargar(numero, _busqueda, _filtros);
      if (version != _version) return;
      // Si se borró lo último de la última página, va a la última que sí tiene datos
      if (resultado.items.isEmpty && resultado.total > 0 && numero > 1) {
        numero = (resultado.total + porPagina - 1) ~/ porPagina;
        resultado = await _cargar(numero, _busqueda, _filtros);
        if (version != _version) return;
      }
      _paginaActual = numero;
      emit(ListaCargada<T>(
        items: resultado.items,
        total: resultado.total,
        hayMas: resultado.hayMas,
        pagina: numero,
        porPagina: porPagina,
      ));
    } on ApiException catch (e) {
      if (version != _version) return;
      emit(vista != null
          ? vista.copiarCon(cargandoPagina: false, errorPagina: e.mensaje)
          : ListaError<T>(e.mensaje));
    } catch (_) {
      if (version != _version) return;
      const mensaje = 'Ocurrió un error inesperado.';
      emit(vista != null
          ? vista.copiarCon(cargandoPagina: false, errorPagina: mensaje)
          : ListaError<T>(mensaje));
    }
  }
}
