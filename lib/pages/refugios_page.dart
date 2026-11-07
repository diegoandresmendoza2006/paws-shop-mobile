import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/gestion_bloc.dart';
import '../bloc/gestion_event.dart';
import '../bloc/gestion_state.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/pagina.dart';
import '../models/refugio.dart';
import '../repositories/admin_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../utils/api_config.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/boton_nuevo.dart';
import '../widgets/botones_gestion.dart';
import '../widgets/confirmar.dart';
import '../widgets/lista_paginada.dart';
import '../widgets/mostrar_aviso.dart';
import 'refugio_form_page.dart';
import '../utils/colores.dart';

/// Gestión de refugios (administrador): buscar, crear, editar y eliminar.
class RefugiosPage extends StatelessWidget {
  const RefugiosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListaBloc<Refugio>>(
          create: (ctx) {
            final repo = ctx.read<RefugioRepository>();
            return ListaBloc<Refugio>((pagina, busqueda, filtros) async {
              // El servidor entrega todos los refugios (son pocos): aquí se buscan y se reparten en páginas
              final todos = await repo.listar();
              final texto = busqueda.trim().toLowerCase();
              final lista = texto.isEmpty
                  ? todos
                  : todos.where((r) => r.nombre.toLowerCase().contains(texto)).toList();
              final desde = (pagina - 1) * ApiConfig.porPagina;
              final trozo = lista.skip(desde).take(ApiConfig.porPagina).toList();
              return Pagina<Refugio>(
                  items: trozo, total: lista.length, hayMas: desde + trozo.length < lista.length);
            })
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
    final lista = context.read<ListaBloc<Refugio>>();
    final guardado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const RefugioFormPage()));
    if (guardado == true) lista.add(const ListaIniciada());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GestionBloc, GestionState>(
      listener: (context, estado) {
        if (estado is GestionExitosa) {
          mostrarTexto(context, estado.mensaje);
          context.read<ListaBloc<Refugio>>().add(const ListaIniciada(silenciosa: true));
        } else if (estado is GestionError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      child: Column(
        children: [
          BotonNuevo(texto: 'Nuevo refugio', alPulsar: () => _nuevo(context)),
          BarraBusqueda(
            pista: 'Buscar refugio…',
            alBuscar: (texto) =>
                context.read<ListaBloc<Refugio>>().add(ListaFiltrada(busqueda: texto)),
          ),
          Expanded(
            child: ListaPaginada<Refugio>(
              textoVacio: 'No hay refugios con esa búsqueda',
              construirItem: (context, r) => _TarjetaRefugio(refugio: r),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaRefugio extends StatelessWidget {
  final Refugio refugio;
  const _TarjetaRefugio({required this.refugio});

  Future<void> _editar(BuildContext context) async {
    final lista = context.read<ListaBloc<Refugio>>();
    final guardado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => RefugioFormPage(refugio: refugio)));
    if (guardado == true) lista.add(const ListaIniciada(silenciosa: true));
  }

  Future<void> _eliminar(BuildContext context) async {
    final gestion = context.read<GestionBloc>();
    final ok = await confirmar(
      context,
      titulo: '¿Eliminar refugio?',
      mensaje: 'Vas a eliminar «${refugio.nombre}». Esta acción no se puede deshacer. '
          'Un refugio con mascotas o encargados asignados no se puede eliminar.',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok) gestion.add(RefugioEliminado(refugio.id));
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme.bodyMedium;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(refugio.nombre, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.place_outlined, size: 16, color: context.textoSecundario),
              const SizedBox(width: 6),
              Expanded(child: Text(refugio.direccion ?? 'Sin dirección', style: texto)),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              Icon(Icons.phone_outlined, size: 16, color: context.textoSecundario),
              const SizedBox(width: 6),
              Expanded(child: Text(refugio.telefono ?? 'Sin teléfono', style: texto)),
            ]),
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
