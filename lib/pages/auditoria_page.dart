import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/registro_auditoria.dart';
import '../repositories/admin_repository.dart';
import '../utils/formato.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/filtro_chips.dart';
import '../widgets/lista_paginada.dart';

/// Auditoría: quién hizo qué y cuándo. Con búsqueda por usuario, filtro por acción y páginas.
class AuditoriaPage extends StatelessWidget {
  const AuditoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaBloc<RegistroAuditoria>>(
      create: (ctx) {
        final repo = ctx.read<AdminRepository>();
        return ListaBloc<RegistroAuditoria>((pagina, busqueda, filtros) =>
            repo.auditoria(pagina: pagina, busqueda: busqueda, accion: filtros['accion']))
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
  String _accion = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BarraBusqueda(
          pista: 'Buscar por usuario…',
          alBuscar: (texto) => context
              .read<ListaBloc<RegistroAuditoria>>()
              .add(ListaFiltrada(busqueda: texto)),
        ),
        FiltroChips(
          opciones: const {
            'Todas': '',
            'Creaciones': 'INSERT',
            'Ediciones': 'UPDATE',
            'Eliminaciones': 'DELETE',
          },
          seleccion: _accion,
          alElegir: (v) {
            setState(() => _accion = v);
            context.read<ListaBloc<RegistroAuditoria>>().add(
                ListaFiltrada(filtros: v.isEmpty ? <String, String>{} : {'accion': v}));
          },
        ),
        Expanded(
          child: ListaPaginada<RegistroAuditoria>(
            textoVacio: 'No hay registros de auditoría con ese filtro',
            construirItem: (context, r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${r.nombreUsuario} · ${r.tablaAfectada}'),
                subtitle: Text(r.fecha == null ? '' : fechaHoraLegible(r.fecha!)),
                trailing: EtiquetaEstado(estado: r.accion),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
