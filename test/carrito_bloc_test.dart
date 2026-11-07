import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paws_shop/bloc/carrito_bloc.dart';
import 'package:paws_shop/bloc/carrito_event.dart';
import 'package:paws_shop/bloc/carrito_state.dart';
import 'package:paws_shop/models/producto.dart';
import 'package:paws_shop/repositories/compra_repository.dart';
import 'package:paws_shop/services/api_service.dart';

const _croquetas = Producto(id: 1, nombre: 'Croquetas', precio: 10000, stock: 2, categoriaId: 1);
const _agotado = Producto(id: 2, nombre: 'Collar', precio: 5000, stock: 0, categoriaId: 1);

CarritoBloc _bloc([Future<http.Response> Function(http.Request)? servidor]) => CarritoBloc(
      CompraRepository(
        api: ApiService(
            client: MockClient(servidor ?? (_) async => http.Response('no', 500))),
      ),
    );

/// Procesa los eventos pendientes antes de mirar el estado.
Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  test('agregar suma cantidades y calcula el total', () async {
    final bloc = _bloc();
    bloc.add(const ProductoAgregado(_croquetas));
    bloc.add(const ProductoAgregado(_croquetas));
    await _esperar();
    expect(bloc.state.cantidadTotal, 2);
    expect(bloc.state.total, 20000);
    await bloc.close();
  });

  test('no deja pasar del stock disponible', () async {
    final bloc = _bloc();
    for (var i = 0; i < 3; i++) {
      bloc.add(const ProductoAgregado(_croquetas)); // stock = 2
    }
    await _esperar();
    expect(bloc.state.cantidadTotal, 2);
    expect(bloc.state.aviso!.esError, isTrue);
    await bloc.close();
  });

  test('un producto agotado no se agrega', () async {
    final bloc = _bloc();
    bloc.add(const ProductoAgregado(_agotado));
    await _esperar();
    expect(bloc.state.estaVacio, isTrue);
    await bloc.close();
  });

  test('bajar la cantidad a 0 quita el producto', () async {
    final bloc = _bloc();
    bloc.add(const ProductoAgregado(_croquetas));
    await _esperar();
    bloc.add(const CantidadCambiada(1, 0));
    await _esperar();
    await _esperar();
    expect(bloc.state.estaVacio, isTrue);
    await bloc.close();
  });

  test('comprar envía los productos y vacía el carrito', () async {
    http.Request? recibida;
    final bloc = _bloc((r) async {
      recibida = r;
      return http.Response.bytes(
        utf8.encode(jsonEncode({'id': 7, 'total': 20000, 'estado_pedido': 'Pagada'})),
        201,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    bloc.add(const ProductoAgregado(_croquetas));
    bloc.add(const ProductoAgregado(_croquetas));
    await _esperar();
    bloc.add(const CompraConfirmada());
    await bloc.stream.firstWhere((s) => s.estaVacio && s.aviso != null);
    expect(recibida!.url.path, '/compras/');
    expect(jsonDecode(recibida!.body), {
      'items': [
        {'producto_id': 1, 'cantidad': 2}
      ]
    });
    expect(bloc.state.aviso!.texto, contains('#7'));
    await bloc.close();
  });

  test('si el servidor rechaza la compra el carrito se conserva', () async {
    final bloc = _bloc((_) async => http.Response.bytes(
          utf8.encode(jsonEncode({'detail': 'Stock insuficiente de Croquetas'})),
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ));
    bloc.add(const ProductoAgregado(_croquetas));
    await _esperar();
    bloc.add(const CompraConfirmada());
    final estado = await bloc.stream.firstWhere((CarritoState s) => !s.comprando && s.aviso?.esError == true);
    expect(estado.items, hasLength(1));
    expect(estado.aviso!.texto, 'Stock insuficiente de Croquetas');
    await bloc.close();
  });
}
