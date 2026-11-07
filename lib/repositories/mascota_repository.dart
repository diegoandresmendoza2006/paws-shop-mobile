import '../models/mascota.dart';
import '../models/pagina.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Intermediario entre el BLoC y la API: pide el JSON al servicio y lo convierte en modelos.
/// Si mañana los datos vienen de otro lado (caché, base local), solo cambia este archivo.
class MascotaRepository {
  final ApiService _api;

  MascotaRepository({ApiService? api}) : _api = api ?? ApiService();

  /// GET /mascotas/buscar  (pública). Filtros + orden + paginación en el servidor.
  Future<Pagina<Mascota>> buscar({
    required int pagina,
    String busqueda = '',
    String? especie,
    String? estado,
    String orden = 'recientes',
  }) async {
    final query = <String, String>{
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
      'orden': orden,
    };
    if (busqueda.trim().isNotEmpty) query['raza'] = busqueda.trim();
    if (especie != null && especie.isNotEmpty) query['especie'] = especie;
    if (estado != null && estado.isNotEmpty) query['estado'] = estado;
    final json = await _api.get('/mascotas/buscar', query: query);
    return Pagina.deCuerpo(json, Mascota.fromJson);
  }

  /// GET /mascotas/gestion/inventario  (personal). El encargado solo ve las de SU refugio.
  Future<Pagina<Mascota>> inventario({
    required int pagina,
    String busqueda = '',
    String? estado,
    String? refugioId,
  }) async {
    final query = <String, String>{
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    };
    if (busqueda.trim().isNotEmpty) query['buscar'] = busqueda.trim();
    if (estado != null && estado.isNotEmpty) query['estado'] = estado;
    if (refugioId != null && refugioId.isNotEmpty) query['refugio_id'] = refugioId;
    final r = await _api.getConTotal('/mascotas/gestion/inventario', query: query);
    return Pagina.deLista(r.datos, r.total, pagina, ApiConfig.porPagina, Mascota.fromJson);
  }

  /// POST /mascotas/  (personal). El encargado siempre crea en SU refugio.
  Future<Mascota> crear(Map<String, dynamic> datos) async {
    final json = await _api.postJson('/mascotas/', datos) as Map<String, dynamic>;
    return Mascota.fromJson(json);
  }

  /// PUT /mascotas/{id}  (personal). Reemplaza todos los datos editables.
  Future<Mascota> editar(int id, Map<String, dynamic> datos) async {
    final json = await _api.putJson('/mascotas/$id', datos) as Map<String, dynamic>;
    return Mascota.fromJson(json);
  }

  /// PATCH /mascotas/{id}  (personal)
  Future<void> cambiarEstado(int id, String estado) async {
    await _api.patchJson('/mascotas/$id', {'estado_adopcion': estado});
  }

  /// DELETE /mascotas/{id}. [forzar] solo lo acepta el administrador (borra también el historial).
  Future<void> eliminar(int id, {bool forzar = false}) async {
    await _api.delete('/mascotas/$id',
        query: forzar ? {'forzar': 'true'} : null);
  }
}
