import '../models/categoria.dart';
import '../models/refugio.dart';

/// Refugios y categorías ya cargados (para llenar las listas desplegables).
sealed class CatalogosState {
  const CatalogosState();
}

class CatalogosCargando extends CatalogosState {
  const CatalogosCargando();
}

class CatalogosCargados extends CatalogosState {
  final List<Refugio> refugios;
  final List<Categoria> categorias;
  const CatalogosCargados({required this.refugios, required this.categorias});

  String nombreDeRefugio(int id) {
    for (final r in refugios) {
      if (r.id == id) return r.nombre;
    }
    return '';
  }

  String nombreDeCategoria(int id) {
    for (final c in categorias) {
      if (c.id == id) return c.nombre;
    }
    return '';
  }
}

class CatalogosError extends CatalogosState {
  final String mensaje;
  const CatalogosError(this.mensaje);
}
