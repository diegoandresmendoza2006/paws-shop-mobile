/// Un encargado de refugio (GET /admin/encargados).
class Encargado {
  final int id;
  final String nombreCompleto;
  final String email;
  final int? refugioId;
  final String? refugioNombre;

  const Encargado({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.refugioId,
    this.refugioNombre,
  });

  factory Encargado.fromJson(Map<String, dynamic> json) => Encargado(
        id: json['id'] as int,
        nombreCompleto: json['nombre_completo'] as String,
        email: json['email'] as String,
        refugioId: json['refugio_id'] as int?,
        refugioNombre: json['refugio_nombre'] as String?,
      );
}
