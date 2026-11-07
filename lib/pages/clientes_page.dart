import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/usuario.dart';
import '../repositories/admin_repository.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/foto_perfil.dart';
import '../widgets/lista_paginada.dart';
import 'cliente_page.dart';

/// El administrador consulta sus clientes (con búsqueda y páginas) y entra a editarlos o eliminarlos.
class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaBloc<Usuario>>(
      create: (ctx) {
        final repo = ctx.read<AdminRepository>();
        return ListaBloc<Usuario>((pagina, busqueda, filtros) =>
            repo.clientes(pagina: pagina, busqueda: busqueda))
          ..add(const ListaIniciada());
      },
      child: Builder(
        builder: (context) => Column(
          children: [
            BarraBusqueda(
              pista: 'Nombre, correo, documento o teléfono…',
              alBuscar: (texto) =>
                  context.read<ListaBloc<Usuario>>().add(ListaFiltrada(busqueda: texto)),
            ),
            Expanded(
              child: ListaPaginada<Usuario>(
                textoVacio: 'No encontramos clientes con esa búsqueda',
                construirItem: (context, c) {
                  final lista = context.read<ListaBloc<Usuario>>();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: FotoPerfil(url: c.fotoUrl, iniciales: c.iniciales),
                      title: Text(c.nombreCompleto, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${c.email}\n${c.documentoTexto}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ClientePage(cliente: c)));
                        // Al volver, se recarga la lista por si se editó o eliminó
                        lista.add(const ListaIniciada(silenciosa: true));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
