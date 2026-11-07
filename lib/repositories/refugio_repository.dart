import '../models/refugio.dart';
import '../services/api_service.dart';

/// Refugios: cualquiera los consulta, solo el administrador los crea, edita o elimina.
class RefugioRepository {
  final ApiService _api;

  RefugioRepository({ApiService? api}) : _api = api ?? ApiService();

  /// GET /refugios/
  Future<List<Refugio>> listar() async {
    final json = await _api.get('/refugios/') as List<dynamic>;
    return json.map((e) => Refugio.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /refugios/
  Future<Refugio> crear(Map<String, dynamic> datos) async {
    final json = await _api.postJson('/refugios/', datos) as Map<String, dynamic>;
    return Refugio.fromJson(json);
  }

  /// PUT /refugios/{id}
  Future<Refugio> editar(int id, Map<String, dynamic> datos) async {
    final json = await _api.putJson('/refugios/$id', datos) as Map<String, dynamic>;
    return Refugio.fromJson(json);
  }

  /// DELETE /refugios/{id}  (el servidor responde 409 si tiene mascotas o encargados)
  Future<void> eliminar(int id) async {
    await _api.delete('/refugios/$id');
  }
}
