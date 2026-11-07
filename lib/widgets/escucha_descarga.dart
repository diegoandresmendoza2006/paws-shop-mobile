import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/descarga_bloc.dart';
import '../bloc/descarga_state.dart';
import 'mostrar_aviso.dart';

/// Cuando el enlace está listo lo abre (el navegador baja el archivo); si falla, avisa.
class EscuchaDescarga extends StatelessWidget {
  final Widget child;
  const EscuchaDescarga({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DescargaBloc, DescargaState>(
      listener: (context, estado) async {
        if (estado is DescargaLista) {
          final abierto = await launchUrl(Uri.parse(estado.url), mode: LaunchMode.externalApplication);
          if (!context.mounted) return;
          mostrarTexto(context,
              abierto ? 'Descargando…' : 'No se pudo abrir la descarga en tu dispositivo.',
              esError: !abierto);
        } else if (estado is DescargaError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      child: child,
    );
  }
}
