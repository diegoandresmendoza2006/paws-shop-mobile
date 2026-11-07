/// Una de las cuentas (roles) de la misma persona: p. ej. "Encargado" y "Usuario".
class Cuenta {
  final int usuarioId;
  final int rolId;
  final String rol;

  const Cuenta({required this.usuarioId, required this.rolId, required this.rol});

  factory Cuenta.fromJson(Map<String, dynamic> json) => Cuenta(
        usuarioId: json['usuario_id'] as int,
        rolId: json['rol_id'] as int,
        rol: json['rol'] as String,
      );
}
