import '../models/categoria.dart';
import '../models/pagina.dart';
import '../models/producto.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Productos de la tienda solidaria.
class ProductoRepository {
  final ApiService _api;

  ProductoRepository({ApiService? api}) : _api = api ?? ApiService();

  /// GET /productos/buscar  (pública)
  Future<Pagina<Producto>> buscar({
    required int pagina,
    String busqueda = '',
    String orden = 'recientes',
  }) async {
    final query = <String, String>{
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
      'orden': orden,
    };
    if (busqueda.trim().isNotEmpty) query['q'] = busqueda.trim();
    final json = await _api.get('/productos/buscar', query: query);
    return Pagina.deCuerpo(json, Producto.fromJson);
  }

  /// GET /productos/categorias
  Future<List<Categoria>> categorias() async {
    final json = await _api.get('/productos/categorias') as List<dynamic>;
    return json.map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /productos/  (personal)
  Future<Producto> crear(Map<String, dynamic> datos) async {
    final json = await _api.postJson('/productos/', datos) as Map<String, dynamic>;
    return Producto.fromJson(json);
  }

  /// PUT /productos/{id}  (personal)
  Future<Producto> editar(int id, Map<String, dynamic> datos) async {
    final json = await _api.putJson('/productos/$id', datos) as Map<String, dynamic>;
    return Producto.fromJson(json);
  }

  /// DELETE /productos/{id}  (el servidor responde 409 si el producto ya se vendió)
  Future<void> eliminar(int id) async {
    await _api.delete('/productos/$id');
  }
}
