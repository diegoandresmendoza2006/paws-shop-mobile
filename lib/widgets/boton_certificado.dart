import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/descarga_bloc.dart';
import '../bloc/descarga_event.dart';
import '../bloc/descarga_state.dart';
import '../repositories/descarga_repository.dart';
import 'escucha_descarga.dart';

/// «Descargar certificado» de una adopción aprobada (PDF).
class BotonCertificado extends StatelessWidget {
  final int solicitudId;
  const BotonCertificado({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => DescargaBloc(ctx.read<DescargaRepository>()),
      child: EscuchaDescarga(
        child: Builder(builder: (context) {
          final preparando = context.watch<DescargaBloc>().state is DescargaPreparando;
          return SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: preparando
                  ? null
                  : () => context.read<DescargaBloc>().add(CertificadoPedido(solicitudId)),
              icon: preparando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.workspace_premium_outlined),
              label: Text(preparando ? 'Preparando…' : 'Descargar certificado de adopción'),
            ),
          );
        }),
      ),
    );
  }
}
