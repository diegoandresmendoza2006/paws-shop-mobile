import 'producto.dart';

/// Un producto dentro del carrito, con su cantidad.
class ItemCarrito {
  final Producto producto;
  final int cantidad;

  const ItemCarrito({required this.producto, required this.cantidad});

  double get subtotal => producto.precio * cantidad;

  ItemCarrito conCantidad(int nueva) =>
      ItemCarrito(producto: producto, cantidad: nueva);
}
