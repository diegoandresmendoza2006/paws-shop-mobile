/// Un refugio de animales (GET /refugios/).
class Refugio {
  final int id;
  final String nombre;
  final String? direccion;
  final String? telefono;

  /// Punto elegido en el mapa por el administrador (puede no estar definido).
  final double? latitud;
  final double? longitud;

  const Refugio({
    required this.id,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.latitud,
    this.longitud,
  });

  /// true si el refugio tiene ubicación en el mapa.
  bool get tieneUbicacion => latitud != null && longitud != null;

  factory Refugio.fromJson(Map<String, dynamic> json) => Refugio(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        direccion: json['direccion'] as String?,
        telefono: json['telefono'] as String?,
        latitud: (json['latitud'] as num?)?.toDouble(),
        longitud: (json['longitud'] as num?)?.toDouble(),
      );
}
