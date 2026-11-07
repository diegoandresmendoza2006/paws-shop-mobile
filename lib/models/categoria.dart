/// Una categoría de productos: Alimento, Juguetes, Accesorios...
class Categoria {
  final int id;
  final String nombre;

  const Categoria({required this.id, required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      Categoria(id: json['id'] as int, nombre: json['nombre'] as String);
}
