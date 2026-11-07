import '../models/item_carrito.dart';
import '../models/orden.dart';
import '../models/pagina.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Compras de la tienda. El carrito vive en la app; solo la COMPRA llega al servidor.
class CompraRepository {
  final ApiService _api;

  CompraRepository({ApiService? api}) : _api = api ?? ApiService();

  /// POST /compras/  -> descuenta el stock y devuelve la orden.
  Future<Orden> comprar(List<ItemCarrito> items) async {
    final json = await _api.postJson('/compras/', {
      'items': items
          .map((i) => {'producto_id': i.producto.id, 'cantidad': i.cantidad})
          .toList(),
    }) as Map<String, dynamic>;
    return Orden.fromJson(json);
  }

  /// GET /compras/mis
  Future<Pagina<Orden>> mias({required int pagina}) async {
    final r = await _api.getConTotal('/compras/mis', query: {
      'pagina': '$pagina',
      'por_pagina': '${ApiConfig.porPagina}',
    });
    return Pagina.deLista(r.datos, r.total, pagina, ApiConfig.porPagina, Orden.fromJson);
  }
}
