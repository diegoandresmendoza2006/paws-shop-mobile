/// Lo que la pantalla le PIDE a una lista paginada (páginas con «Anterior» y «Siguiente»).
sealed class ListaEvent {
  const ListaEvent();
}

/// "Carga (o recarga) la lista".
/// * [silenciosa] = false: vuelve a la página 1 mostrando el circulito de carga.
/// * [silenciosa] = true: recarga la página donde estás, sin quitar lo que se ve
///   (se usa después de editar, eliminar o al "jalar para actualizar").
class ListaIniciada extends ListaEvent {
  final bool silenciosa;
  const ListaIniciada({this.silenciosa = false});
}

/// "Llévame a esta página" (la numeración empieza en 1).
class ListaPaginaSolicitada extends ListaEvent {
  final int pagina;
  const ListaPaginaSolicitada(this.pagina);
}

/// "Cambió la búsqueda o los filtros": vuelve a la página 1. Lo que sea null no se toca.
class ListaFiltrada extends ListaEvent {
  final String? busqueda;
  final Map<String, String>? filtros;
  const ListaFiltrada({this.busqueda, this.filtros});
}
