import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/item_carrito.dart';
import '../repositories/compra_repository.dart';
import '../services/api_service.dart';
import '../utils/formato.dart';
import 'aviso.dart';
import 'carrito_event.dart';
import 'carrito_state.dart';

/// El carrito de compras. Vive en la app (como en Angular); solo la compra llega al servidor.
class CarritoBloc extends Bloc<CarritoEvent, CarritoState> {
  final CompraRepository _repositorio;

  CarritoBloc(this._repositorio) : super(const CarritoState()) {
    on<ProductoAgregado>(_alAgregar);
    on<CantidadCambiada>(_alCambiarCantidad);
    on<ProductoQuitado>(_alQuitar);
    on<CarritoVaciado>((e, emit) => emit(const CarritoState()));
    on<CompraConfirmada>(_alComprar);
  }

  void _alAgregar(ProductoAgregado e, Emitter<CarritoState> emit) {
    final p = e.producto;
    if (!p.hayStock) {
      emit(state.copiarCon(aviso: Aviso('${p.nombre} está agotado', esError: true)));
      return;
    }
    final lista = [...state.items];
    final i = lista.indexWhere((x) => x.producto.id == p.id);
    if (i == -1) {
      lista.add(ItemCarrito(producto: p, cantidad: 1));
    } else {
      if (lista[i].cantidad >= p.stock) {
        emit(state.copiarCon(
            aviso: Aviso('Solo hay ${p.stock} de ${p.nombre}', esError: true)));
        return;
      }
      lista[i] = lista[i].conCantidad(lista[i].cantidad + 1);
    }
    emit(state.copiarCon(items: lista, aviso: Aviso('${p.nombre} agregado al carrito')));
  }

  void _alCambiarCantidad(CantidadCambiada e, Emitter<CarritoState> emit) {
    if (e.cantidad <= 0) {
      add(ProductoQuitado(e.productoId));
      return;
    }
    final lista = [...state.items];
    final i = lista.indexWhere((x) => x.producto.id == e.productoId);
    if (i == -1) return;
    final stock = lista[i].producto.stock;
    if (e.cantidad > stock) {
      emit(state.copiarCon(aviso: Aviso('Solo hay $stock disponibles', esError: true)));
      return;
    }
    lista[i] = lista[i].conCantidad(e.cantidad);
    emit(state.copiarCon(items: lista));
  }

  void _alQuitar(ProductoQuitado e, Emitter<CarritoState> emit) {
    emit(state.copiarCon(
        items: state.items.where((x) => x.producto.id != e.productoId).toList()));
  }

  Future<void> _alComprar(CompraConfirmada e, Emitter<CarritoState> emit) async {
    if (state.estaVacio || state.comprando) return;
    emit(state.copiarCon(comprando: true));
    try {
      final orden = await _repositorio.comprar(state.items);
      emit(CarritoState(
          aviso: Aviso('¡Compra realizada! Pedido #${orden.id} por ${moneda(orden.total)}')));
    } on ApiException catch (ex) {
      emit(state.copiarCon(comprando: false, aviso: Aviso(ex.mensaje, esError: true)));
    } catch (_) {
      emit(state.copiarCon(
          comprando: false, aviso: Aviso('Ocurrió un error inesperado.', esError: true)));
    }
  }
}
