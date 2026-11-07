import '../models/pagina.dart';
import '../models/seguimiento.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Reportes de seguimiento de las mascotas adoptadas.
class SeguimientoRepository {
  final ApiService _api;

  SeguimientoRepository({ApiService? api}) : _api = api ?? ApiService();

  /// [delPersonal] = true usa GET /seguimientos/ (encargado/admin); false usa GET /seguimientos/mis.
  Future<Pagina<Seguimiento>> listar({required int pagina, required bool delPersonal}) async {
    final r = await _api.getConTotal(delPersonal ? '/seguimientos/' : '/seguimientos/mis',
        query: {'pagina': '$pagina', 'por_pagina': '${ApiConfig.porPagina}'});
    return Pagina.deLista(
        r.datos, r.total, pagina, ApiConfig.porPagina, Seguimiento.fromJson);
  }

  /// POST /seguimientos/  (el adoptante reporta cómo está su mascota)
  Future<void> enviar({
    required int solicitudId,
    required String estadoSalud,
    String? observaciones,
  }) async {
    await _api.postJson('/seguimientos/', {
      'solicitud_id': solicitudId,
      'estado_salud': estadoSalud,
      'observaciones_texto': observaciones,
    });
  }
}
