import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/carrito_bloc.dart';
import '../bloc/carrito_event.dart';
import '../bloc/favoritos_bloc.dart';
import '../bloc/favoritos_event.dart';
import '../bloc/favoritos_state.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/mascota.dart';
import '../models/pagina.dart';
import '../models/producto.dart';
import '../repositories/favorito_repository.dart';
import '../utils/api_config.dart';
import '../widgets/lista_paginada.dart';
import '../widgets/tarjeta_mascota.dart';
import '../widgets/tarjeta_producto.dart';
import 'detalle_mascota_page.dart';
import 'producto_detalle_page.dart';

/// Mis favoritos: las mascotas y los productos que marqué con el corazón.
class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListaBloc<Mascota>>(
          create: (ctx) {
            final repo = ctx.read<FavoritoRepository>();
            return ListaBloc<Mascota>(
                (pagina, busqueda, filtros) => repo.mascotas(pagina: pagina))
              ..add(const ListaIniciada());
          },
        ),
        BlocProvider<ListaBloc<Producto>>(
          create: (ctx) {
            final repo = ctx.read<FavoritoRepository>();
            return ListaBloc<Producto>((pagina, busqueda, filtros) async {
              // Los productos favoritos llegan todos juntos (son pocos): se reparten en páginas aquí
              final lista = await repo.productos();
              final desde = (pagina - 1) * ApiConfig.porPagina;
              final trozo = lista.skip(desde).take(ApiConfig.porPagina).toList();
              return Pagina<Producto>(
                  items: trozo, total: lista.length, hayMas: desde + trozo.length < lista.length);
            })
              ..add(const ListaIniciada());
          },
        ),
      ],
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis favoritos'),
          bottom: const TabBar(tabs: [Tab(text: 'Mascotas'), Tab(text: 'Productos')]),
        ),
        // Cuando cambia un corazón, las dos listas se actualizan en silencio
        body: BlocListener<FavoritosBloc, FavoritosState>(
          listenWhen: (a, b) =>
              a.mascotas.length != b.mascotas.length ||
              a.productos.length != b.productos.length,
          listener: (context, estado) {
            context.read<ListaBloc<Mascota>>().add(const ListaIniciada(silenciosa: true));
            context.read<ListaBloc<Producto>>().add(const ListaIniciada(silenciosa: true));
          },
          child: TabBarView(
            children: [
              ListaPaginada<Mascota>(
                textoVacio: 'Aún no tienes mascotas favoritas.\nToca el corazón en el catálogo.',
                construirItem: (context, m) => TarjetaMascota(
                  mascota: m,
                  esFavorita: true,
                  alAlternarFavorito: () =>
                      context.read<FavoritosBloc>().add(MascotaAlternada(m.id)),
                  alTocar: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DetalleMascotaPage(mascota: m))),
                ),
              ),
              ListaPaginada<Producto>(
                textoVacio: 'Aún no tienes productos favoritos.\nToca el corazón en la tienda.',
                construirItem: (context, p) => TarjetaProducto(
                  producto: p,
                  esFavorito: true,
                  alAlternarFavorito: () =>
                      context.read<FavoritosBloc>().add(ProductoAlternado(p.id)),
                  alAgregar: () => context.read<CarritoBloc>().add(ProductoAgregado(p)),
                  alAbrir: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => ProductoDetallePage(producto: p))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
