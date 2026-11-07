/// Pide las listas cortas que necesitan los formularios (refugios y categorías).
sealed class CatalogosEvent {
  const CatalogosEvent();
}

class CatalogosSolicitados extends CatalogosEvent {
  const CatalogosSolicitados();
}
