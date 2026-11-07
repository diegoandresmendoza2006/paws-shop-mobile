import '../models/producto.dart';

/// Lo que la pantalla le PIDE al CarritoBloc.
sealed class CarritoEvent {
  const CarritoEvent();
}

class ProductoAgregado extends CarritoEvent {
  final Producto producto;
  const ProductoAgregado(this.producto);
}

class CantidadCambiada extends CarritoEvent {
  final int productoId;
  final int cantidad;
  const CantidadCambiada(this.productoId, this.cantidad);
}

class ProductoQuitado extends CarritoEvent {
  final int productoId;
  const ProductoQuitado(this.productoId);
}

class CarritoVaciado extends CarritoEvent {
  const CarritoVaciado();
}

/// "Pagar": envía la compra al servidor.
class CompraConfirmada extends CarritoEvent {
  const CompraConfirmada();
}
