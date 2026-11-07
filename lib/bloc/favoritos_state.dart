import 'aviso.dart';

/// Qué mascotas y productos son favoritos (solo los ids: lo justo para pintar los corazones).
class FavoritosState {
  final Set<int> mascotas;
  final Set<int> productos;
  final Aviso? aviso;

  const FavoritosState({this.mascotas = const {}, this.productos = const {}, this.aviso});

  bool esMascotaFavorita(int id) => mascotas.contains(id);
  bool esProductoFavorito(int id) => productos.contains(id);
}
