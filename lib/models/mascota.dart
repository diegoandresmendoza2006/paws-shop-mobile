/// Una mascota tal como la devuelve la API (GET /mascotas/).
/// Es el equivalente de la interfaz `Mascota` de Angular (models/modelos.ts).
class Mascota {
  final int id;
  final String nombre;
  final String especie;
  final String? raza;
  final int? edadMeses;
  final String? descripcion;
  final String estadoAdopcion;
  final int refugioId;
  final String? imagenUrl;

  const Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    this.raza,
    this.edadMeses,
    this.descripcion,
    required this.estadoAdopcion,
    required this.refugioId,
    this.imagenUrl,
  });

  /// Convierte el JSON de la API (claves en snake_case) a un objeto Dart.
  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      especie: json['especie'] as String,
      raza: json['raza'] as String?,
      edadMeses: json['edad_meses'] as int?,
      descripcion: json['descripcion'] as String?,
      estadoAdopcion: json['estado_adopcion'] as String,
      refugioId: json['refugio_id'] as int,
      imagenUrl: json['imagen_url'] as String?,
    );
  }

  /// "8 meses", "1 año", "2 años y 3 meses" (igual que edadTexto de Angular).
  String get edadTexto {
    final m = edadMeses;
    if (m == null) return 'Edad desconocida';
    if (m < 12) return m == 1 ? '1 mes' : '$m meses';
    final anios = m ~/ 12;
    final resto = m % 12;
    final a = anios == 1 ? '1 año' : '$anios años';
    if (resto == 0) return a;
    return '$a y ${resto == 1 ? '1 mes' : '$resto meses'}';
  }
}
