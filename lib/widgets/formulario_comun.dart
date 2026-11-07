import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/formulario_bloc.dart';
import '../bloc/formulario_state.dart';
import 'mostrar_aviso.dart';

/// Escucha el resultado del guardado: si salió bien avisa y cierra el formulario devolviendo `true`
/// (la lista de atrás se recarga); si falló, muestra el error y deja corregir.
class EscuchaFormulario extends StatelessWidget {
  final Widget child;
  const EscuchaFormulario({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormularioBloc, FormularioState>(
      listener: (context, estado) {
        if (estado is FormularioExitoso) {
          mostrarTexto(context, estado.mensaje);
          Navigator.of(context).pop(true);
        } else if (estado is FormularioError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      child: child,
    );
  }
}

/// Botón «Guardar»: se desactiva y muestra "Guardando…" mientras se envía.
class BotonGuardar extends StatelessWidget {
  final String texto;
  final VoidCallback alPulsar;
  const BotonGuardar({super.key, required this.texto, required this.alPulsar});

  @override
  Widget build(BuildContext context) {
    final guardando = context.watch<FormularioBloc>().state is FormularioGuardando;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: guardando ? null : alPulsar,
        child: Text(guardando ? 'Guardando…' : texto),
      ),
    );
  }
}
