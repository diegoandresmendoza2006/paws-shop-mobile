import '../models/encargado.dart';
import '../models/mes_historial.dart';
import '../models/metricas.dart';
import '../models/pagina.dart';
import '../models/registro_auditoria.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Todo lo que solo puede hacer el administrador: métricas, auditoría y gestión de clientes.
class AdminRepository {
  final ApiService _api;

  AdminRepository({ApiService? api}) : _api = api ?? ApiService();

  /// GET /admin/metricas  ([mes] = '2026-11'; sin mes = el mes actual)
  Future<Metricas> metricas({String? mes}) async {
    final json = await _api.get('/admin/metricas', query: mes == null ? null : {'mes': mes})
        as Map<String, dynamic>;
    return Metricas.fromJson(json);
  }

  /// GET /admin/metricas/meses  (mes a mes, desde el primer movimiento hasta hoy)
  Future<List<MesHistorial>> historial() async {
    final json = await _api.get('/admin/metricas/meses') as List<dynamic>;
    return json.map((e) => MesHistorial.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /admin/auditoria (con búsqueda por usuario y filtro por acción)
  Future<Pagina<RegistroAuditoria>> auditoria({
    required int pagina,
    String busqueda = '',
    String? accion,
  }) async {
    final query = <String, String>{
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    };
    if (busqueda.trim().isNotEmpty) query['buscar'] = busqueda.trim();
    if (accion != null && accion.isNotEmpty) query['accion'] = accion;
    final r = await _api.getConTotal('/admin/auditoria', query: query);
    return Pagina.deLista(
        r.datos, r.total, pagina, ApiConfig.porPagina, RegistroAuditoria.fromJson);
  }

  /// GET /admin/clientes (busca por nombre, correo, documento o teléfono)
  Future<Pagina<Usuario>> clientes({required int pagina, String busqueda = ''}) async {
    final query = <String, String>{
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    };
    if (busqueda.trim().isNotEmpty) query['buscar'] = busqueda.trim();
    final json = await _api.get('/admin/clientes', query: query);
    return Pagina.deCuerpo(json, Usuario.fromJson);
  }

  /// PUT /admin/clientes/{id}
  Future<void> editarCliente(int id, Map<String, dynamic> datos) async {
    await _api.putJson('/admin/clientes/$id', datos);
  }

  /// DELETE /admin/clientes/{id}  (falla con 409 si el cliente tiene historial)
  Future<void> eliminarCliente(int id, {bool forzar = false}) async {
    await _api.delete('/admin/clientes/$id', query: forzar ? {'forzar': 'true'} : null);
  }

  /// GET /admin/encargados (con búsqueda por nombre o correo)
  Future<Pagina<Encargado>> encargados({required int pagina, String busqueda = ''}) async {
    final query = <String, String>{
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    };
    if (busqueda.trim().isNotEmpty) query['buscar'] = busqueda.trim();
    final r = await _api.getConTotal('/admin/encargados', query: query);
    return Pagina.deLista(r.datos, r.total, pagina, ApiConfig.porPagina, Encargado.fromJson);
  }

  /// POST /admin/encargados
  Future<Encargado> crearEncargado(Map<String, dynamic> datos) async {
    final json = await _api.postJson('/admin/encargados', datos) as Map<String, dynamic>;
    return Encargado.fromJson(json);
  }

  /// PUT /admin/encargados/{id}  (la contraseña solo viaja si se quiere cambiar)
  Future<Encargado> editarEncargado(int id, Map<String, dynamic> datos) async {
    final json = await _api.putJson('/admin/encargados/$id', datos) as Map<String, dynamic>;
    return Encargado.fromJson(json);
  }

  /// DELETE /admin/encargados/{id}  (409 si tiene historial; con [forzar] se borra también el historial)
  Future<void> eliminarEncargado(int id, {bool forzar = false}) async {
    await _api.delete('/admin/encargados/$id', query: forzar ? {'forzar': 'true'} : null);
  }
}
