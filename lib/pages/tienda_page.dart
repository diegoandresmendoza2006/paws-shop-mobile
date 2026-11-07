import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/carrito_bloc.dart';
import '../bloc/carrito_event.dart';
import '../bloc/favoritos_bloc.dart';
import '../bloc/favoritos_event.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/producto.dart';
import '../repositories/producto_repository.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/filtro_chips.dart';
import '../widgets/lista_paginada.dart';
import '../widgets/tarjeta_producto.dart';
import 'producto_detalle_page.dart';

/// Tienda solidaria. [conCompra] = true para el cliente (corazón y carrito);
/// false para el personal, que solo consulta el inventario.
class TiendaPage extends StatelessWidget {
  final bool conCompra;
  const TiendaPage({super.key, required this.conCompra});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaBloc<Producto>>(
      create: (ctx) {
        final repo = ctx.read<ProductoRepository>();
        return ListaBloc<Producto>((pagina, busqueda, filtros) => repo.buscar(
              pagina: pagina,
              busqueda: busqueda,
              orden: filtros['orden'] ?? 'recientes',
            ))
          ..add(const ListaIniciada());
      },
      child: _Contenido(conCompra: conCompra),
    );
  }
}

class _Contenido extends StatefulWidget {
  final bool conCompra;
  const _Contenido({required this.conCompra});

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  String _orden = 'recientes';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BarraBusqueda(
          pista: 'Buscar productos…',
          alBuscar: (texto) =>
              context.read<ListaBloc<Producto>>().add(ListaFiltrada(busqueda: texto)),
        ),
        FiltroChips(
          opciones: const {
            'Recientes': 'recientes',
            'Menor precio': 'precio_asc',
            'Mayor precio': 'precio_desc',
            'A-Z': 'nombre',
          },
          seleccion: _orden,
          alElegir: (v) {
            setState(() => _orden = v);
            context.read<ListaBloc<Producto>>().add(ListaFiltrada(filtros: {'orden': v}));
          },
        ),
        Expanded(
          child: ListaPaginada<Producto>(
            textoVacio: 'No encontramos productos con esa búsqueda',
            construirItem: (context, p) => widget.conCompra
                ? _TarjetaCliente(producto: p)
                : TarjetaProducto(producto: p, alAbrir: () => abrirDetalleProducto(context, p)),
          ),
        ),
      ],
    );
  }
}

class _TarjetaCliente extends StatelessWidget {
  final Producto producto;
  const _TarjetaCliente({required this.producto});

  @override
  Widget build(BuildContext context) {
    final favorito = context
        .select<FavoritosBloc, bool>((b) => b.state.esProductoFavorito(producto.id));
    return TarjetaProducto(
      producto: producto,
      esFavorito: favorito,
      alAlternarFavorito: () =>
          context.read<FavoritosBloc>().add(ProductoAlternado(producto.id)),
      alAgregar: () => context.read<CarritoBloc>().add(ProductoAgregado(producto)),
      alAbrir: () => abrirDetalleProducto(context, producto),
    );
  }
}

/// Abre la pantalla con la foto, el precio y la descripción del producto.
void abrirDetalleProducto(BuildContext context, Producto producto) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductoDetallePage(producto: producto)));
}
