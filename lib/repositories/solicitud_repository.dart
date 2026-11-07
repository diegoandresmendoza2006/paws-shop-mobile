import '../models/pagina.dart';
import '../models/solicitud_adopcion.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Solicitudes de adopción (las del usuario y las que gestiona el personal).
class SolicitudRepository {
  final ApiService _api;

  SolicitudRepository({ApiService? api}) : _api = api ?? ApiService();

  /// POST /adopciones/
  Future<void> enviar(SolicitudAdopcionNueva solicitud) async {
    await _api.postJson('/adopciones/', solicitud.toJson());
  }

  /// GET /adopciones/mis
  Future<Pagina<SolicitudAdopcion>> mias({required int pagina}) async {
    final r = await _api.getConTotal('/adopciones/mis', query: {
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    });
    return Pagina.deLista(
        r.datos, r.total, pagina, ApiConfig.porPagina, SolicitudAdopcion.fromJson);
  }

  /// Las adopciones APROBADAS del usuario (las únicas de las que se puede reportar seguimiento).
  Future<Pagina<SolicitudAdopcion>> aprobadas() async {
    final r = await _api.getConTotal('/adopciones/mis',
        query: {'estado': 'Aprobada', 'pagina': '1', 'por_pagina': '100'});
    return Pagina.deLista(r.datos, r.total, 1, 100, SolicitudAdopcion.fromJson);
  }

  /// GET /adopciones/  (personal). El encargado solo ve las de su refugio.
  Future<Pagina<SolicitudAdopcion>> delPersonal({
    required int pagina,
    String busqueda = '',
    String? estado,
  }) async {
    final query = <String, String>{
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    };
    if (busqueda.trim().isNotEmpty) query['buscar'] = busqueda.trim();
    if (estado != null && estado.isNotEmpty) query['estado'] = estado;
    final r = await _api.getConTotal('/adopciones/', query: query);
    return Pagina.deLista(
        r.datos, r.total, pagina, ApiConfig.porPagina, SolicitudAdopcion.fromJson);
  }

  /// PATCH /adopciones/{id}  -> 'Aprobada' o 'Rechazada' (con comentario para el adoptante)
  Future<void> resolver(int id, String estado, String comentario) async {
    await _api.patchJson('/adopciones/$id', {
      'estado': estado,
      'comentario': comentario.trim().isEmpty ? null : comentario.trim(),
    });
  }
}
