/// Un refugio de animales (GET /refugios/).
class Refugio {
  final int id;
  final String nombre;
  final String? direccion;
  final String? telefono;

  const Refugio({required this.id, required this.nombre, this.direccion, this.telefono});

  factory Refugio.fromJson(Map<String, dynamic> json) => Refugio(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        direccion: json['direccion'] as String?,
        telefono: json['telefono'] as String?,
      );
}
