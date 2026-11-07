import '../models/mascota.dart';
import '../models/pagina.dart';
import '../models/producto.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Favoritos del usuario (se guardan en el servidor: no se pierden al cambiar de celular).
class FavoritoRepository {
  final ApiService _api;

  FavoritoRepository({ApiService? api}) : _api = api ?? ApiService();

  /// GET /favoritos/mascotas/ids
  Future<Set<int>> idsDeMascotas() async {
    final lista = await _api.get('/favoritos/mascotas/ids') as List<dynamic>;
    return lista.map((e) => e as int).toSet();
  }

  /// GET /favoritos/productos  (devuelve todos; son pocos)
  Future<List<Producto>> productos() async {
    final lista = await _api.get('/favoritos/productos') as List<dynamic>;
    return lista.map((e) => Producto.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /favoritos/mascotas (paginado)
  Future<Pagina<Mascota>> mascotas({required int pagina}) async {
    final json = await _api.get('/favoritos/mascotas', query: {
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    });
    return Pagina.deCuerpo(json, Mascota.fromJson);
  }

  Future<void> marcarMascota(int id) => _api.put('/favoritos/mascotas/$id');
  Future<void> quitarMascota(int id) => _api.delete('/favoritos/mascotas/$id');
  Future<void> marcarProducto(int id) => _api.put('/favoritos/productos/$id');
  Future<void> quitarProducto(int id) => _api.delete('/favoritos/productos/$id');
}
