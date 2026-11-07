import '../models/item_carrito.dart';
import 'aviso.dart';

/// Lo que el CarritoBloc le RESPONDE a la pantalla.
class CarritoState {
  final List<ItemCarrito> items;
  final bool comprando;
  final Aviso? aviso;

  const CarritoState({this.items = const [], this.comprando = false, this.aviso});

  double get total => items.fold(0.0, (suma, i) => suma + i.subtotal);
  int get cantidadTotal => items.fold(0, (suma, i) => suma + i.cantidad);
  bool get estaVacio => items.isEmpty;

  CarritoState copiarCon({List<ItemCarrito>? items, bool? comprando, Aviso? aviso}) =>
      CarritoState(
        items: items ?? this.items,
        comprando: comprando ?? this.comprando,
        aviso: aviso,
      );
}
