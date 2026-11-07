import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/gestion_bloc.dart';
import '../bloc/gestion_event.dart';
import '../bloc/gestion_state.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/encargado.dart';
import '../repositories/admin_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/boton_nuevo.dart';
import '../widgets/botones_gestion.dart';
import '../widgets/confirmar.dart';
import '../widgets/confirmar_eliminar_todo.dart';
import '../widgets/lista_paginada.dart';
import '../widgets/mostrar_aviso.dart';
import 'encargado_form_page.dart';
import '../utils/colores.dart';

/// Los encargados de refugio (administrador): buscar, crear, editar y eliminar cuentas.
class EncargadosPage extends StatelessWidget {
  const EncargadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListaBloc<Encargado>>(
          create: (ctx) {
            final repo = ctx.read<AdminRepository>();
            return ListaBloc<Encargado>((pagina, busqueda, filtros) =>
                repo.encargados(pagina: pagina, busqueda: busqueda))
              ..add(const ListaIniciada());
          },
        ),
        BlocProvider<GestionBloc>(
          create: (ctx) => GestionBloc(
            admin: ctx.read<AdminRepository>(),
            solicitudes: ctx.read<SolicitudRepository>(),
            mascotas: ctx.read<MascotaRepository>(),
            productos: ctx.read<ProductoRepository>(),
            refugios: ctx.read<RefugioRepository>(),
          ),
        ),
      ],
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  Future<void> _nuevo(BuildContext context) async {
    final lista = context.read<ListaBloc<Encargado>>();
    final creado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const EncargadoFormPage()));
    if (creado == true) lista.add(const ListaIniciada());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GestionBloc, GestionState>(
      listener: (context, estado) {
        if (estado is GestionExitosa) {
          mostrarTexto(context, estado.mensaje);
          context.read<ListaBloc<Encargado>>().add(const ListaIniciada(silenciosa: true));
        } else if (estado is GestionConflicto) {
          preguntarEliminarTodo(
            context,
            nombre: 'Este encargado',
            alConfirmar: () => context.read<GestionBloc>().add(estado.eventoForzado),
          );
        } else if (estado is GestionError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      child: Column(
        children: [
          BotonNuevo(texto: 'Nuevo encargado', alPulsar: () => _nuevo(context)),
          BarraBusqueda(
            pista: 'Buscar por nombre o correo…',
            alBuscar: (texto) =>
                context.read<ListaBloc<Encargado>>().add(ListaFiltrada(busqueda: texto)),
          ),
          Expanded(
            child: ListaPaginada<Encargado>(
              textoVacio: 'No hay encargados con esa búsqueda',
              construirItem: (context, e) => _TarjetaEncargado(encargado: e),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaEncargado extends StatelessWidget {
  final Encargado encargado;
  const _TarjetaEncargado({required this.encargado});

  Future<void> _editar(BuildContext context) async {
    final lista = context.read<ListaBloc<Encargado>>();
    final guardado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => EncargadoFormPage(encargado: encargado)));
    if (guardado == true) lista.add(const ListaIniciada(silenciosa: true));
  }

  Future<void> _eliminar(BuildContext context) async {
    final gestion = context.read<GestionBloc>();
    final ok = await confirmar(
      context,
      titulo: '¿Eliminar encargado?',
      mensaje: 'Vas a eliminar la cuenta de encargado de «${encargado.nombreCompleto}». '
          'Esta acción no se puede deshacer.',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok) gestion.add(EncargadoEliminado(encargado.id));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.verdeSuave,
                  child: Icon(Icons.badge_outlined, color: context.verdeFuerte),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(encargado.nombreCompleto,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(encargado.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(encargado.refugioNombre ?? 'Sin refugio',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            BotonesGestion(
              alEditar: () => _editar(context),
              alEliminar: () => _eliminar(context),
            ),
          ],
        ),
      ),
    );
  }
}
