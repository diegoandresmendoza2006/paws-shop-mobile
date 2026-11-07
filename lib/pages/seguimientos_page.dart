import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/seguimiento.dart';
import '../repositories/seguimiento_repository.dart';
import '../utils/formato.dart';
import '../widgets/boton_nuevo.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/lista_paginada.dart';
import 'seguimiento_form_page.dart';
import '../utils/colores.dart';

/// Reportes de seguimiento de las mascotas adoptadas.
/// [delPersonal] = true muestra los de todo el refugio; false, solo los del usuario
/// (que además puede enviar un reporte nuevo).
class SeguimientosPage extends StatelessWidget {
  final bool delPersonal;
  const SeguimientosPage({super.key, required this.delPersonal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaBloc<Seguimiento>>(
      create: (ctx) {
        final repo = ctx.read<SeguimientoRepository>();
        return ListaBloc<Seguimiento>((pagina, busqueda, filtros) =>
            repo.listar(pagina: pagina, delPersonal: delPersonal))
          ..add(const ListaIniciada());
      },
      child: Builder(
        builder: (context) => Column(
          children: [
            if (!delPersonal)
              BotonNuevo(
                texto: 'Reportar seguimiento',
                alPulsar: () async {
                  final lista = context.read<ListaBloc<Seguimiento>>();
                  final enviado = await Navigator.of(context)
                      .push<bool>(MaterialPageRoute(builder: (_) => const SeguimientoFormPage()));
                  if (enviado == true) lista.add(const ListaIniciada());
                },
              ),
            Expanded(
              child: ListaPaginada<Seguimiento>(
                textoVacio: delPersonal
                    ? 'Todavía no hay reportes de seguimiento'
                    : 'Aún no has enviado reportes de seguimiento',
                construirItem: (context, s) => _TarjetaSeguimiento(seguimiento: s, delPersonal: delPersonal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaSeguimiento extends StatelessWidget {
  final Seguimiento seguimiento;
  final bool delPersonal;
  const _TarjetaSeguimiento({required this.seguimiento, required this.delPersonal});

  @override
  Widget build(BuildContext context) {
    final s = seguimiento;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart_outlined, color: context.verdeFuerte),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.mascotaNombre ?? 'Mascota',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                EtiquetaEstado(estado: s.estadoSalud),
              ],
            ),
            const SizedBox(height: 6),
            if (delPersonal && s.adoptanteNombre != null)
              Text('Adoptante: ${s.adoptanteNombre}', style: Theme.of(context).textTheme.bodyMedium),
            if (s.fechaReporte != null)
              Text(fechaHoraLegible(s.fechaReporte!), style: Theme.of(context).textTheme.bodySmall),
            if ((s.observaciones ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(s.observaciones!),
            ],
          ],
        ),
      ),
    );
  }
}
