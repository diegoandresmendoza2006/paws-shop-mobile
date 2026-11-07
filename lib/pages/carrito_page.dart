import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/carrito_bloc.dart';
import '../bloc/carrito_event.dart';
import '../bloc/carrito_state.dart';
import '../models/item_carrito.dart';
import '../utils/formato.dart';
import '../widgets/confirmar.dart';
import '../widgets/foto_mascota.dart';
import '../utils/colores.dart';

/// El carrito: cambia cantidades, quita productos y paga.
class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarritoBloc, CarritoState>(
      builder: (context, estado) {
        if (estado.estaVacio) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Tu carrito está vacío', textAlign: TextAlign.center),
                  SizedBox(height: 4),
                  Text('Agrega productos desde la pestaña Tienda.',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                itemCount: estado.items.length,
                itemBuilder: (context, i) => _FilaCarrito(item: estado.items[i]),
              ),
            ),
            Material(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total (${estado.cantidadTotal} productos)'),
                        Text(moneda(estado.total),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      icon: estado.comprando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.payment),
                      label: const Text('Pagar'),
                      onPressed: estado.comprando
                          ? null
                          : () async {
                              final bloc = context.read<CarritoBloc>();
                              final ok = await confirmar(context,
                                  titulo: 'Confirmar compra',
                                  mensaje: 'Vas a pagar ${moneda(estado.total)}. ¿Continuar?',
                                  textoConfirmar: 'Pagar');
                              if (ok) bloc.add(const CompraConfirmada());
                            },
                    ),
                    TextButton(
                      onPressed: estado.comprando
                          ? null
                          : () => context.read<CarritoBloc>().add(const CarritoVaciado()),
                      child: const Text('Vaciar carrito'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilaCarrito extends StatelessWidget {
  final ItemCarrito item;
  const _FilaCarrito({required this.item});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CarritoBloc>();
    final p = item.producto;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(width: 84, height: 84, child: FotoMascota(url: p.imagenUrl)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nombre, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${moneda(p.precio)} c/u',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(moneda(item.subtotal),
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: context.verdeFuerte)),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Quitar uno',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () =>
                        bloc.add(CantidadCambiada(p.id, item.cantidad - 1)),
                  ),
                  Text('${item.cantidad}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  IconButton(
                    tooltip: 'Agregar uno',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () =>
                        bloc.add(CantidadCambiada(p.id, item.cantidad + 1)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => bloc.add(ProductoQuitado(p.id)),
                child: const Text('Quitar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
