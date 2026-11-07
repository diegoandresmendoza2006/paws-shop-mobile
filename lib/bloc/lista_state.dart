/// Lo que el ListaBloc le RESPONDE a la pantalla: en qué situación está la lista.
sealed class ListaState<T> {
  const ListaState();
}

class ListaInicial<T> extends ListaState<T> {
  const ListaInicial();
}

class ListaCargando<T> extends ListaState<T> {
  const ListaCargando();
}

/// La página [pagina] ya está cargada: [items] son solo los de ESA página.
class ListaCargada<T> extends ListaState<T> {
  final List<T> items;

  /// Cuántos resultados hay en total (en todas las páginas).
  final int total;
  final bool hayMas;

  /// Página actual (empieza en 1) y cuántos elementos trae cada página.
  final int pagina;
  final int porPagina;

  /// Está pidiendo otra página: se sigue viendo la actual con una barrita de progreso.
  final bool cargandoPagina;

  /// Falló el cambio de página: se conserva la actual y se avisa.
  final String? errorPagina;

  const ListaCargada({
    required this.items,
    required this.total,
    required this.hayMas,
    this.pagina = 1,
    this.porPagina = 5,
    this.cargandoPagina = false,
    this.errorPagina,
  });

  /// Cuántas páginas hay en total (mínimo 1).
  int get totalPaginas {
    if (total <= 0 || porPagina <= 0) return 1;
    return (total + porPagina - 1) ~/ porPagina;
  }

  bool get hayAnterior => pagina > 1;
  bool get haySiguiente => pagina < totalPaginas;

  ListaCargada<T> copiarCon({bool? cargandoPagina, String? errorPagina, bool limpiarError = false}) {
    return ListaCargada<T>(
      items: items,
      total: total,
      hayMas: hayMas,
      pagina: pagina,
      porPagina: porPagina,
      cargandoPagina: cargandoPagina ?? this.cargandoPagina,
      errorPagina: limpiarError ? null : (errorPagina ?? this.errorPagina),
    );
  }
}

class ListaError<T> extends ListaState<T> {
  final String mensaje;
  const ListaError(this.mensaje);
}
