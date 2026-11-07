/// Un bloque de resultados (una "página") de una lista que se carga por partes.
class Pagina<T> {
  final List<T> items;
  final int total;
  final bool hayMas;
  const Pagina({required this.items, required this.total, required this.hayMas});

  /// Para respuestas del tipo {"items": [...], "total": 30, "pagina": 1, "paginas": 3}
  /// (mascotas/buscar, productos/buscar, admin/clientes, favoritos/mascotas).
  static Pagina<T> deCuerpo<T>(
    dynamic json,
    T Function(Map<String, dynamic>) convertir,
  ) {
    final mapa = json as Map<String, dynamic>;
    final lista = (mapa['items'] as List<dynamic>)
        .map((e) => convertir(e as Map<String, dynamic>))
        .toList();
    return Pagina<T>(
      items: lista,
      total: mapa['total'] as int,
      hayMas: (mapa['pagina'] as int) < (mapa['paginas'] as int),
    );
  }

  /// Para respuestas que son una lista simple y mandan el total en la cabecera X-Total-Count
  /// (solicitudes, auditoría, compras, seguimientos...).
  static Pagina<T> deLista<T>(
    dynamic json,
    int? total,
    int pagina,
    int porPagina,
    T Function(Map<String, dynamic>) convertir,
  ) {
    final lista = (json as List<dynamic>)
        .map((e) => convertir(e as Map<String, dynamic>))
        .toList();
    final hayMas = total != null
        ? pagina * porPagina < total
        : lista.length >= porPagina;
    return Pagina<T>(items: lista, total: total ?? lista.length, hayMas: hayMas);
  }
}
