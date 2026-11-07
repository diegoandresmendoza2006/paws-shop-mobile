/// Lo que el DescargaBloc le RESPONDE a la pantalla.
sealed class DescargaState {
  const DescargaState();
}

class DescargaInicial extends DescargaState {
  const DescargaInicial();
}

class DescargaPreparando extends DescargaState {
  const DescargaPreparando();
}

/// El enlace ya está listo: la pantalla lo abre y el navegador baja el archivo.
class DescargaLista extends DescargaState {
  final String url;
  const DescargaLista(this.url);
}

class DescargaError extends DescargaState {
  final String mensaje;
  const DescargaError(this.mensaje);
}
