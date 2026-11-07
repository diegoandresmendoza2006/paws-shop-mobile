import '../utils/formato.dart';

/// Un reporte de seguimiento de una mascota adoptada.
class Seguimiento {
  final int id;
  final int solicitudId;
  final DateTime? fechaReporte;
  final String estadoSalud;
  final String? observaciones;
  final String? mascotaNombre;
  final String? adoptanteNombre;

  const Seguimiento({
    required this.id,
    required this.solicitudId,
    this.fechaReporte,
    required this.estadoSalud,
    this.observaciones,
    this.mascotaNombre,
    this.adoptanteNombre,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> j) => Seguimiento(
        id: j['id'] as int,
        solicitudId: j['solicitud_id'] as int,
        fechaReporte: fechaDeApi(j['fecha_reporte']),
        estadoSalud: j['estado_salud'] as String,
        observaciones: j['observaciones_texto'] as String?,
        mascotaNombre: j['mascota_nombre'] as String?,
        adoptanteNombre: j['adoptante_nombre'] as String?,
      );
}
