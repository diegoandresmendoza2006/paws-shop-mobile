import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/carrito_bloc.dart';
import '../bloc/carrito_event.dart';
import '../bloc/favoritos_bloc.dart';
import '../bloc/favoritos_event.dart';
import '../models/producto.dart';
import '../utils/formato.dart';
import '../widgets/foto_mascota.dart';
import '../utils/colores.dart';

/// Detalle de un producto: foto grande, precio, existencias y su descripción
/// (igual que el detalle de una mascota). Solo el usuario ve «Agregar al carrito» y el corazón.
class ProductoDetallePage extends StatelessWidget {
  final Producto producto;
  const ProductoDetallePage({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<AuthBloc>().state;
    final esUsuario = sesion is AuthAutenticado && sesion.sesion.usuario.esUsuario;
    final agotado = !producto.hayStock;
    final sinDescripcion = (producto.descripcion ?? '').trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        actions: [
          if (esUsuario)
            Builder(builder: (context) {
              final favorito = context
                  .select<FavoritosBloc, bool>((b) => b.state.esProductoFavorito(producto.id));
              return IconButton(
                tooltip: favorito ? 'Quitar de favoritos' : 'Agregar a favoritos',
                icon: Icon(favorito ? Icons.favorite : Icons.favorite_border,
                    color: favorito ? const Color(0xFFD32F2F) : null),
                onPressed: () => context.read<FavoritosBloc>().add(ProductoAlternado(producto.id)),
              );
            }),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(aspectRatio: 4 / 3, child: FotoMascota(url: producto.imagenUrl)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(moneda(producto.precio),
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800, color: context.verdeFuerte)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: agotado ? context.rojoSuave : context.verdeSuave,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        agotado ? 'Agotado' : 'Quedan ${producto.stock}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: agotado ? context.rojoFuerte : context.verdeFuerte,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Descripción', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(sinDescripcion
                    ? 'Este producto todavía no tiene una descripción.'
                    : producto.descripcion!.trim()),
                const SizedBox(height: 24),
                if (esUsuario)
                  FilledButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(agotado ? 'Agotado' : 'Agregar al carrito'),
                    onPressed:
                        agotado ? null : () => context.read<CarritoBloc>().add(ProductoAgregado(producto)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
