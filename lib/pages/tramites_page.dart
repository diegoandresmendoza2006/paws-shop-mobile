import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/orden.dart';
import '../models/solicitud_adopcion.dart';
import '../repositories/compra_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../utils/formato.dart';
import '../widgets/boton_certificado.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/lista_paginada.dart';
import 'seguimientos_page.dart';
import '../utils/colores.dart';

/// Los trámites del cliente: sus solicitudes de adopción, sus compras y el seguimiento.
class TramitesPage extends StatelessWidget {
  const TramitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: const [
          TabBar(tabs: [
            Tab(text: 'Adopciones'),
            Tab(text: 'Compras'),
            Tab(text: 'Seguimiento'),
          ]),
          Expanded(
            child: TabBarView(children: [
              _MisSolicitudes(),
              _MisCompras(),
              SeguimientosPage(delPersonal: false),
            ]),
          ),
        ],
      ),
    );
  }
}

class _MisSolicitudes extends StatelessWidget {
  const _MisSolicitudes();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaBloc<SolicitudAdopcion>>(
      create: (ctx) {
        final repo = ctx.read<SolicitudRepository>();
        return ListaBloc<SolicitudAdopcion>(
            (pagina, busqueda, filtros) => repo.mias(pagina: pagina))
          ..add(const ListaIniciada());
      },
      child: ListaPaginada<SolicitudAdopcion>(
        textoVacio: 'Aún no has enviado solicitudes de adopción',
        construirItem: (context, s) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Adopción de ${s.mascotaNombre ?? 'mascota'}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    EtiquetaEstado(estado: s.estado),
                  ],
                ),
                if (s.fechaSolicitud != null)
                  Text('Enviada el ${fechaLegible(s.fechaSolicitud!)}',
                      style: Theme.of(context).textTheme.bodySmall),
                if ((s.comentarioEncargado ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.verdeSuave,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Mensaje del refugio: ${s.comentarioEncargado}'),
                  ),
                ],
                if (s.estado == 'Aprobada') ...[
                  const SizedBox(height: 10),
                  BotonCertificado(solicitudId: s.id),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MisCompras extends StatelessWidget {
  const _MisCompras();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaBloc<Orden>>(
      create: (ctx) {
        final repo = ctx.read<CompraRepository>();
        return ListaBloc<Orden>((pagina, busqueda, filtros) => repo.mias(pagina: pagina))
          ..add(const ListaIniciada());
      },
      child: ListaPaginada<Orden>(
        textoVacio: 'Aún no has hecho compras',
        construirItem: (context, o) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text('Pedido #${o.id}'),
            subtitle: Text(o.fecha == null ? '' : fechaHoraLegible(o.fecha!)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(moneda(o.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                EtiquetaEstado(estado: o.estadoPedido),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
