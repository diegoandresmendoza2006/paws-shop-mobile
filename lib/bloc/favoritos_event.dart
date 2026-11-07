/// Lo que la pantalla le PIDE al FavoritosBloc.
sealed class FavoritosEvent {
  const FavoritosEvent();
}

/// "Trae mis favoritos" (se pide al entrar).
class FavoritosCargados extends FavoritosEvent {
  const FavoritosCargados();
}

/// Tocó el corazón de una mascota: si era favorita la quita; si no, la agrega.
class MascotaAlternada extends FavoritosEvent {
  final int mascotaId;
  const MascotaAlternada(this.mascotaId);
}

/// Tocó el corazón de un producto.
class ProductoAlternado extends FavoritosEvent {
  final int productoId;
  const ProductoAlternado(this.productoId);
}

/// Se cerró la sesión: olvida todo.
class FavoritosReiniciados extends FavoritosEvent {
  const FavoritosReiniciados();
}
