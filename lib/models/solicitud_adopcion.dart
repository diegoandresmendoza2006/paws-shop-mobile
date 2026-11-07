import '../utils/formato.dart';

/// El formulario de adopción que se ENVÍA (POST /adopciones/).
class SolicitudAdopcionNueva {
  final int mascotaId;
  final String nombreContacto;
  final DateTime fechaNacimiento;
  final String telefono;
  final String emailContacto;
  final String direccion;
  final String tipoVivienda; // 'Propia' | 'Arrendada'
  final bool viviendaPermiteMascotas;
  final bool tienePatio;
  final bool tieneCercas;
  final int personasHogar;
  final bool tuvoMascotas;
  final bool? mascotasVacunadas;
  final bool? mascotasEsterilizadas;
  final int horasSolo;
  final String responsableViajes;
  final String motivo;

  const SolicitudAdopcionNueva({
    required this.mascotaId,
    required this.nombreContacto,
    required this.fechaNacimiento,
    required this.telefono,
    required this.emailContacto,
    required this.direccion,
    required this.tipoVivienda,
    required this.viviendaPermiteMascotas,
    required this.tienePatio,
    required this.tieneCercas,
    required this.personasHogar,
    required this.tuvoMascotas,
    this.mascotasVacunadas,
    this.mascotasEsterilizadas,
    required this.horasSolo,
    required this.responsableViajes,
    this.motivo = '',
  });

  /// Claves en snake_case, como las espera la API.
  Map<String, dynamic> toJson() => {
        'mascota_id': mascotaId,
        'nombre_contacto': nombreContacto,
        'fecha_nacimiento': fechaParaApi(fechaNacimiento),
        'telefono': telefono,
        'email_contacto': emailContacto,
        'direccion': direccion,
        'tipo_vivienda': tipoVivienda,
        'vivienda_permite_mascotas': viviendaPermiteMascotas,
        'tiene_patio': tienePatio,
        'tiene_cercas': tieneCercas,
        'personas_hogar': personasHogar,
        'tuvo_mascotas': tuvoMascotas,
        'mascotas_vacunadas': tuvoMascotas ? mascotasVacunadas : null,
        'mascotas_esterilizadas': tuvoMascotas ? mascotasEsterilizadas : null,
        'horas_solo': horasSolo,
        'responsable_viajes': responsableViajes,
        'motivo': motivo.trim().isEmpty ? null : motivo.trim(),
      };
}

/// Una solicitud ya enviada, tal como la devuelve la API (mis trámites / solicitudes del refugio).
class SolicitudAdopcion {
  final int id;
  final int mascotaId;
  final String estado;
  final DateTime? fechaSolicitud;
  final String? mascotaNombre;
  final String? adoptanteNombre;
  final String? nombreContacto;
  final DateTime? fechaNacimiento;
  final String? telefono;
  final String? emailContacto;
  final String? direccion;
  final String? tipoVivienda;
  final bool? viviendaPermiteMascotas;
  final bool? tienePatio;
  final bool? tieneCercas;
  final int? personasHogar;
  final bool? tuvoMascotas;
  final bool? mascotasVacunadas;
  final bool? mascotasEsterilizadas;
  final int? horasSolo;
  final String? responsableViajes;
  final String? motivo;
  final String? comentarioEncargado;
  final DateTime? fechaRespuesta;

  const SolicitudAdopcion({
    required this.id,
    required this.mascotaId,
    required this.estado,
    this.fechaSolicitud,
    this.mascotaNombre,
    this.adoptanteNombre,
    this.nombreContacto,
    this.fechaNacimiento,
    this.telefono,
    this.emailContacto,
    this.direccion,
    this.tipoVivienda,
    this.viviendaPermiteMascotas,
    this.tienePatio,
    this.tieneCercas,
    this.personasHogar,
    this.tuvoMascotas,
    this.mascotasVacunadas,
    this.mascotasEsterilizadas,
    this.horasSolo,
    this.responsableViajes,
    this.motivo,
    this.comentarioEncargado,
    this.fechaRespuesta,
  });

  factory SolicitudAdopcion.fromJson(Map<String, dynamic> j) => SolicitudAdopcion(
        id: j['id'] as int,
        mascotaId: j['mascota_id'] as int,
        estado: j['estado'] as String,
        fechaSolicitud: fechaDeApi(j['fecha_solicitud']),
        mascotaNombre: j['mascota_nombre'] as String?,
        adoptanteNombre: j['adoptante_nombre'] as String?,
        nombreContacto: j['nombre_contacto'] as String?,
        fechaNacimiento: fechaDeApi(j['fecha_nacimiento']),
        telefono: j['telefono'] as String?,
        emailContacto: j['email_contacto'] as String?,
        direccion: j['direccion'] as String?,
        tipoVivienda: j['tipo_vivienda'] as String?,
        viviendaPermiteMascotas: j['vivienda_permite_mascotas'] as bool?,
        tienePatio: j['tiene_patio'] as bool?,
        tieneCercas: j['tiene_cercas'] as bool?,
        personasHogar: j['personas_hogar'] as int?,
        tuvoMascotas: j['tuvo_mascotas'] as bool?,
        mascotasVacunadas: j['mascotas_vacunadas'] as bool?,
        mascotasEsterilizadas: j['mascotas_esterilizadas'] as bool?,
        horasSolo: j['horas_solo'] as int?,
        responsableViajes: j['responsable_viajes'] as String?,
        motivo: j['motivo'] as String?,
        comentarioEncargado: j['comentario_encargado'] as String?,
        fechaRespuesta: fechaDeApi(j['fecha_respuesta']),
      );

  bool get enRevision => estado == 'En Revisión';
}
