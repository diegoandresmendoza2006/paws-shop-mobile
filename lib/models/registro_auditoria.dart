import '../utils/formato.dart';

/// Una fila de la auditoría: quién hizo qué y cuándo (GET /admin/auditoria).
class RegistroAuditoria {
  final int id;
  final String nombreUsuario;
  final String accion; // INSERT | UPDATE | DELETE
  final String tablaAfectada;
  final DateTime? fecha;

  const RegistroAuditoria({
    required this.id,
    required this.nombreUsuario,
    required this.accion,
    required this.tablaAfectada,
    this.fecha,
  });

  factory RegistroAuditoria.fromJson(Map<String, dynamic> j) => RegistroAuditoria(
        id: j['id'] as int,
        nombreUsuario: j['nombre_usuario'] as String,
        accion: j['accion'] as String,
        tablaAfectada: j['tabla_afectada'] as String,
        fecha: fechaDeApi(j['fecha_accion']),
      );
}
