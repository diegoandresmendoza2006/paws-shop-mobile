import 'package:flutter_test/flutter_test.dart';
import 'package:paws_shop/bloc/lista_bloc.dart';
import 'package:paws_shop/bloc/lista_event.dart';
import 'package:paws_shop/bloc/lista_state.dart';
import 'package:paws_shop/models/pagina.dart';
import 'package:paws_shop/services/api_service.dart';

/// Cargador falso: cada página trae 2 números y hay 2 páginas.
Future<Pagina<int>> _dosPaginas(int p, String busqueda, Map<String, String> filtros) async =>
    Pagina<int>(items: [p * 10, p * 10 + 1], total: 4, hayMas: p < 2);

void main() {
  test('carga la primera página y cambia de página (sin scroll infinito)', () async {
    final bloc = ListaBloc<int>(_dosPaginas, porPagina: 2);
    bloc.add(const ListaIniciada());
    final primera = await bloc.stream.firstWhere((s) => s is ListaCargada<int>);
    expect((primera as ListaCargada<int>).items, [10, 11]);
    expect(primera.pagina, 1);
    expect(primera.totalPaginas, 2);
    expect(primera.haySiguiente, isTrue);
    expect(primera.hayAnterior, isFalse);

    bloc.add(const ListaPaginaSolicitada(2));
    final segunda = await bloc.stream
        .firstWhere((s) => s is ListaCargada<int> && s.pagina == 2 && !s.cargandoPagina);
    // Muestra SOLO la página 2: no acumula la anterior
    expect((segunda as ListaCargada<int>).items, [20, 21]);
    expect(segunda.haySiguiente, isFalse);
    expect(segunda.hayAnterior, isTrue);
    await bloc.close();
  });

  test('buscar vuelve a la primera página con el texto', () async {
    final pedidos = <String>[];
    final bloc = ListaBloc<int>((p, b, f) async {
      pedidos.add('$p|$b|${f['estado']}');
      return Pagina<int>(items: [p], total: 1, hayMas: false);
    });
    bloc.add(const ListaIniciada());
    await bloc.stream.firstWhere((s) => s is ListaCargada<int>);
    bloc.add(const ListaFiltrada(busqueda: 'rex', filtros: {'estado': 'Disponible'}));
    await bloc.stream.firstWhere((s) => s is ListaCargada<int> && pedidos.length == 2);
    expect(pedidos, ['1||null', '1|rex|Disponible']);
    await bloc.close();
  });

  test('si falla la primera página emite ListaError con el mensaje', () async {
    final bloc = ListaBloc<int>((p, b, f) async => throw const ApiException('Sin conexión'));
    bloc.add(const ListaIniciada());
    final error = await bloc.stream.firstWhere((s) => s is ListaError<int>);
    expect((error as ListaError<int>).mensaje, 'Sin conexión');
    await bloc.close();
  });

  test('si falla al cambiar de página conserva la actual y muestra el error', () async {
    var llamadas = 0;
    final bloc = ListaBloc<int>((p, b, f) async {
      llamadas++;
      if (p == 2) throw const ApiException('Se cortó internet');
      return Pagina<int>(items: [1, 2], total: 4, hayMas: true);
    }, porPagina: 2);
    bloc.add(const ListaIniciada());
    await bloc.stream.firstWhere((s) => s is ListaCargada<int>);
    bloc.add(const ListaPaginaSolicitada(2));
    final estado = await bloc.stream
        .firstWhere((s) => s is ListaCargada<int> && s.errorPagina != null);
    expect((estado as ListaCargada<int>).items, [1, 2]);
    expect(estado.pagina, 1);
    expect(estado.errorPagina, 'Se cortó internet');
    expect(llamadas, 2);
    await bloc.close();
  });

  test('si se vacía la última página, vuelve a la última con datos', () async {
    var borrado = false;
    final bloc = ListaBloc<int>((p, b, f) async {
      if (!borrado) return Pagina<int>(items: [p], total: 3, hayMas: p < 2);
      // ya solo quedan 2 elementos: la página 2 quedó vacía
      return p == 1
          ? const Pagina<int>(items: [1, 2], total: 2, hayMas: false)
          : const Pagina<int>(items: [], total: 2, hayMas: false);
    }, porPagina: 2);
    bloc.add(const ListaIniciada());
    await bloc.stream.firstWhere((s) => s is ListaCargada<int>);
    bloc.add(const ListaPaginaSolicitada(2));
    await bloc.stream.firstWhere((s) => s is ListaCargada<int> && s.pagina == 2 && !s.cargandoPagina);
    borrado = true;
    bloc.add(const ListaIniciada(silenciosa: true));
    final fin = await bloc.stream
        .firstWhere((s) => s is ListaCargada<int> && !s.cargandoPagina && s.pagina == 1);
    expect((fin as ListaCargada<int>).items, [1, 2]);
    await bloc.close();
  });

  test('actualizar en silencio no vuelve a mostrar el spinner', () async {
    final bloc = ListaBloc<int>(_dosPaginas);
    bloc.add(const ListaIniciada());
    await bloc.stream.firstWhere((s) => s is ListaCargada<int>);
    final estados = <ListaState<int>>[];
    final sub = bloc.stream.listen(estados.add);
    bloc.add(const ListaIniciada(silenciosa: true));
    await bloc.stream.firstWhere((s) => s is ListaCargada<int>);
    await sub.cancel();
    expect(estados.whereType<ListaCargando<int>>(), isEmpty);
    await bloc.close();
  });
}
