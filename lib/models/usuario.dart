import '../utils/formato.dart';

/// El usuario que inició sesión (GET /auth/me). Equivale a `Usuario` en Angular.
class Usuario {
  final int id;
  final String nombreCompleto;
  final String email;
  final int rolId;
  final int? refugioId;
  final DateTime? fechaNacimiento;
  final String? telefono;
  final String? direccion;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? fotoUrl;
  final DateTime? fechaRegistro;

  const Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rolId,
    this.refugioId,
    this.fechaNacimiento,
    this.telefono,
    this.direccion,
    this.tipoDocumento,
    this.numeroDocumento,
    this.fotoUrl,
    this.fechaRegistro,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombreCompleto: json['nombre_completo'] as String,
      email: json['email'] as String,
      rolId: json['rol_id'] as int,
      refugioId: json['refugio_id'] as int?,
      fechaNacimiento: fechaDeApi(json['fecha_nacimiento']),
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      tipoDocumento: json['tipo_documento'] as String?,
      numeroDocumento: json['numero_documento'] as String?,
      fotoUrl: json['foto_url'] as String?,
      fechaRegistro: fechaDeApi(json['fecha_registro']),
    );
  }

  bool get esAdmin => rolId == 1;
  bool get esEncargado => rolId == 2;
  bool get esUsuario => rolId == 3;

  String get rol {
    switch (rolId) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Encargado';
      default:
        return 'Usuario';
    }
  }

  /// ¿Tiene los datos que pide el formulario de adopción?
  bool get perfilCompleto =>
      fechaNacimiento != null &&
      (telefono ?? '').isNotEmpty &&
      (direccion ?? '').isNotEmpty;

  String get iniciales {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    final primera = partes.first.isEmpty ? '?' : partes.first[0];
    final segunda = partes.length > 1 ? partes[1][0] : '';
    return (primera + segunda).toUpperCase();
  }

  String get documentoTexto =>
      (tipoDocumento == null || numeroDocumento == null)
          ? 'Sin documento'
          : '$tipoDocumento $numeroDocumento';
}
