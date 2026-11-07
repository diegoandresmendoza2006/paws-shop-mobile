/// Un producto de la tienda solidaria.
class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final int categoriaId;
  final String? imagenUrl;

  const Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    required this.categoriaId,
    this.imagenUrl,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        descripcion: json['descripcion'] as String?,
        precio: (json['precio'] as num).toDouble(),
        stock: json['stock'] as int,
        categoriaId: json['categoria_id'] as int,
        imagenUrl: json['imagen_url'] as String?,
      );

  bool get hayStock => stock > 0;
}
