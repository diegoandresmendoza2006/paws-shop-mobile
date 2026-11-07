import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/solicitud_adopcion.dart';
import '../repositories/solicitud_repository.dart';
import '../utils/formato.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/filtro_chips.dart';
import '../widgets/lista_paginada.dart';
import 'solicitud_detalle_page.dart';

/// Solicitudes de adopción que gestiona el encargado (las de su refugio).
class SolicitudesPage extends StatelessWidget {
  const SolicitudesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaBloc<SolicitudAdopcion>>(
      create: (ctx) {
        final repo = ctx.read<SolicitudRepository>();
        return ListaBloc<SolicitudAdopcion>((pagina, busqueda, filtros) =>
            repo.delPersonal(pagina: pagina, busqueda: busqueda, estado: filtros['estado']))
          ..add(const ListaIniciada());
      },
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatefulWidget {
  const _Contenido();

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  String _estado = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BarraBusqueda(
          pista: 'Buscar por mascota o adoptante…',
          alBuscar: (texto) => context
              .read<ListaBloc<SolicitudAdopcion>>()
              .add(ListaFiltrada(busqueda: texto)),
        ),
        FiltroChips(
          opciones: const {
            'Todas': '',
            'En Revisión': 'En Revisión',
            'Aprobada': 'Aprobada',
            'Rechazada': 'Rechazada',
          },
          seleccion: _estado,
          alElegir: (v) {
            setState(() => _estado = v);
            context.read<ListaBloc<SolicitudAdopcion>>().add(
                ListaFiltrada(filtros: v.isEmpty ? <String, String>{} : {'estado': v}));
          },
        ),
        Expanded(
          child: ListaPaginada<SolicitudAdopcion>(
            textoVacio: 'No hay solicitudes con ese filtro',
            construirItem: (context, s) {
              final lista = context.read<ListaBloc<SolicitudAdopcion>>();
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text('${s.adoptanteNombre ?? 'Adoptante'} → ${s.mascotaNombre ?? 'mascota'}'),
                  subtitle: Text(
                      s.fechaSolicitud == null ? '' : 'Enviada el ${fechaLegible(s.fechaSolicitud!)}'),
                  trailing: EtiquetaEstado(estado: s.estado),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SolicitudDetallePage(solicitud: s)));
                    lista.add(const ListaIniciada(silenciosa: true));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
