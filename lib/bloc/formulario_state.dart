/// Cómo va el guardado de un formulario.
sealed class FormularioState {
  const FormularioState();
}

class FormularioInicial extends FormularioState {
  const FormularioInicial();
}

class FormularioGuardando extends FormularioState {
  const FormularioGuardando();
}

class FormularioExitoso extends FormularioState {
  final String mensaje;
  const FormularioExitoso(this.mensaje);
}

class FormularioError extends FormularioState {
  final String mensaje;
  const FormularioError(this.mensaje);
}
