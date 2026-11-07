import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../bloc/lista_state.dart';
import 'pantalla_carga.dart';
import 'vista_error.dart';
import '../utils/colores.dart';

/// Lista por PÁGINAS: muestra los resultados de una página y, al final, los botones
/// «Anterior» y «Siguiente» con "Página 2 de 5". Pide cada página al servidor.
/// También permite "jalar para actualizar". Necesita un `ListaBloc<T>` arriba en el árbol.
class ListaPaginada<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T item) construirItem;
  final String textoVacio;
  final EdgeInsets padding;

  /// Widgets que van arriba de los resultados y se desplazan con ellos (botón «Nueva…», etc.).
  final List<Widget> encabezado;

  const ListaPaginada({
    super.key,
    required this.construirItem,
    this.textoVacio = 'No hay resultados',
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 16),
    this.encabezado = const [],
  });

  @override
  State<ListaPaginada<T>> createState() => _ListaPaginadaState<T>();
}

class _ListaPaginadaState<T> extends State<ListaPaginada<T>> {
  final ScrollController _scroll = ScrollController();
  int _paginaVista = 1;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Al cambiar de página, vuelve al inicio de la lista.
  void _alCambiarPagina(int pagina) {
    if (pagina == _paginaVista) return;
    _paginaVista = pagina;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  Future<void> _actualizar() async {
    final bloc = context.read<ListaBloc<T>>();
    bloc.add(const ListaIniciada(silenciosa: true));
    await bloc.stream.firstWhere((s) => s is ListaCargada<T> && !s.cargandoPagina || s is ListaError<T>);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListaBloc<T>, ListaState<T>>(
      builder: (context, estado) {
        if (estado is ListaError<T>) {
          return VistaError(
            mensaje: estado.mensaje,
            alReintentar: () => context.read<ListaBloc<T>>().add(const ListaIniciada()),
          );
        }
        if (estado is! ListaCargada<T>) {
          return const PantallaCarga(compacta: true);
        }
        _alCambiarPagina(estado.pagina);
        return RefreshIndicator(
          onRefresh: _actualizar,
          child: ListView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: widget.padding,
            children: [
              ...widget.encabezado,
              if (estado.cargandoPagina)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(),
                ),
              if (estado.errorPagina != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(estado.errorPagina!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.rojoFuerte, fontWeight: FontWeight.w600)),
                ),
              if (estado.items.isEmpty) ...[
                const SizedBox(height: 60),
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(widget.textoVacio, textAlign: TextAlign.center),
              ] else ...[
                for (final item in estado.items) widget.construirItem(context, item),
                _Paginador<T>(estado: estado),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// «‹ Anterior»   Página 2 de 5 · 23 resultados   «Siguiente ›»
class _Paginador<T> extends StatelessWidget {
  final ListaCargada<T> estado;
  const _Paginador({required this.estado});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ListaBloc<T>>();
    final ocupado = estado.cargandoPagina;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: estado.hayAnterior && !ocupado
                ? () => bloc.add(ListaPaginaSolicitada(estado.pagina - 1))
                : null,
            icon: const Icon(Icons.chevron_left, size: 18),
            label: const Text('Anterior'),
          ),
          Expanded(
            child: Column(
              children: [
                Text('Página ${estado.pagina} de ${estado.totalPaginas}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${estado.total} resultado${estado.total == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          FilledButton.icon(
            iconAlignment: IconAlignment.end,
            onPressed: estado.haySiguiente && !ocupado
                ? () => bloc.add(ListaPaginaSolicitada(estado.pagina + 1))
                : null,
            icon: const Icon(Icons.chevron_right, size: 18),
            label: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }
}
