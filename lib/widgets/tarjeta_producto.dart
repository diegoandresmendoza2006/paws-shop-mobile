import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../utils/formato.dart';
import 'foto_mascota.dart';
import '../utils/colores.dart';

/// Una tarjeta de producto: foto, nombre, precio y stock. Si es de un cliente trae el corazón
/// y el botón de agregar al carrito; si es de consulta (personal) solo muestra los datos.
class TarjetaProducto extends StatelessWidget {
  final Producto producto;
  final bool? esFavorito;
  final VoidCallback? alAlternarFavorito;
  final VoidCallback? alAgregar;
  final VoidCallback? alAbrir; // toca la tarjeta: abre el detalle con la descripción

  const TarjetaProducto({
    super.key,
    required this.producto,
    this.esFavorito,
    this.alAlternarFavorito,
    this.alAgregar,
    this.alAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final agotado = !producto.hayStock;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alAbrir,
        child: Row(
        children: [
          SizedBox(width: 100, height: 100, child: FotoMascota(url: producto.imagenUrl)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.nombre,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if ((producto.descripcion ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(producto.descripcion!.trim(),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 4),
                  Text(moneda(producto.precio),
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: context.verdeFuerte)),
                  const SizedBox(height: 2),
                  Text(
                    agotado ? 'Agotado' : 'Quedan ${producto.stock}',
                    style: TextStyle(
                        fontSize: 12,
                        color: agotado ? context.rojoFuerte : context.textoSecundario,
                        fontWeight: agotado ? FontWeight.w700 : FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esFavorito != null)
                IconButton(
                  tooltip: esFavorito! ? 'Quitar de favoritos' : 'Agregar a favoritos',
                  icon: Icon(esFavorito! ? Icons.favorite : Icons.favorite_border,
                      color: esFavorito! ? const Color(0xFFD32F2F) : null),
                  onPressed: alAlternarFavorito,
                ),
              if (alAgregar != null)
                IconButton(
                  tooltip: 'Agregar al carrito',
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: agotado ? null : alAgregar,
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
