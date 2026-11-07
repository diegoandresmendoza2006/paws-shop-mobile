import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/catalogos_bloc.dart';
import '../bloc/catalogos_event.dart';
import '../bloc/catalogos_state.dart';
import '../bloc/gestion_bloc.dart';
import '../bloc/gestion_event.dart';
import '../bloc/gestion_state.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/producto.dart';
import '../repositories/admin_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../utils/formato.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/boton_nuevo.dart';
import '../widgets/botones_gestion.dart';
import '../widgets/confirmar.dart';
import '../widgets/foto_mascota.dart';
import '../widgets/lista_paginada.dart';
import '../widgets/mostrar_aviso.dart';
import 'producto_detalle_page.dart';
import 'producto_form_page.dart';
import '../utils/colores.dart';

/// Gestión de productos (encargado y administrador): buscar, crear, editar y eliminar.
class ProductosGestionPage extends StatelessWidget {
  const ProductosGestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListaBloc<Producto>>(
          create: (ctx) {
            final repo = ctx.read<ProductoRepository>();
            return ListaBloc<Producto>((pagina, busqueda, filtros) =>
                repo.buscar(pagina: pagina, busqueda: busqueda))
              ..add(const ListaIniciada());
          },
        ),
        BlocProvider<CatalogosBloc>(
          create: (ctx) => CatalogosBloc(ctx.read<RefugioRepository>(), ctx.read<ProductoRepository>())
            ..add(const CatalogosSolicitados()),
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
    final lista = context.read<ListaBloc<Producto>>();
    final guardado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const ProductoFormPage()));
    if (guardado == true) lista.add(const ListaIniciada());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GestionBloc, GestionState>(
      listener: (context, estado) {
        if (estado is GestionExitosa) {
          mostrarTexto(context, estado.mensaje);
          context.read<ListaBloc<Producto>>().add(const ListaIniciada(silenciosa: true));
        } else if (estado is GestionError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      child: Column(
        children: [
          BotonNuevo(texto: 'Nuevo producto', alPulsar: () => _nuevo(context)),
          BarraBusqueda(
            pista: 'Buscar producto…',
            alBuscar: (texto) =>
                context.read<ListaBloc<Producto>>().add(ListaFiltrada(busqueda: texto)),
          ),
          Expanded(
            child: ListaPaginada<Producto>(
              textoVacio: 'No hay productos con esa búsqueda',
              construirItem: (context, p) => _TarjetaGestion(producto: p),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaGestion extends StatelessWidget {
  final Producto producto;
  const _TarjetaGestion({required this.producto});

  Future<void> _editar(BuildContext context) async {
    final lista = context.read<ListaBloc<Producto>>();
    final guardado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => ProductoFormPage(producto: producto)));
    if (guardado == true) lista.add(const ListaIniciada(silenciosa: true));
  }

  Future<void> _eliminar(BuildContext context) async {
    final gestion = context.read<GestionBloc>();
    final ok = await confirmar(
      context,
      titulo: '¿Eliminar producto?',
      mensaje: 'Vas a eliminar «${producto.nombre}». Esta acción no se puede deshacer. '
          'Si ya se vendió, ponle stock 0 para que aparezca como agotado.',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok) gestion.add(ProductoEliminado(producto.id));
  }

  @override
  Widget build(BuildContext context) {
    final catalogos = context.watch<CatalogosBloc>().state;
    final categoria = catalogos is CatalogosCargados ? catalogos.nombreDeCategoria(producto.categoriaId) : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ProductoDetallePage(producto: producto))),
              child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(width: 64, height: 64, child: FotoMascota(url: producto.imagenUrl)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if ((producto.descripcion ?? '').trim().isNotEmpty)
                        Text(producto.descripcion!.trim(),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      Text.rich(TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(text: categoria.isEmpty ? 'Stock: ' : '$categoria · Stock: '),
                          TextSpan(
                            text: '${producto.stock}',
                            style: producto.hayStock
                                ? null
                                : TextStyle(color: context.rojoFuerte, fontWeight: FontWeight.w800),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                Text(moneda(producto.precio),
                    style: TextStyle(fontWeight: FontWeight.w800, color: context.verdeFuerte)),
              ],
            ),
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
