import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paws_shop/models/mascota.dart';
import 'package:paws_shop/repositories/mascota_repository.dart';
import 'package:paws_shop/services/api_service.dart';

MascotaRepository _repoCon(Future<http.Response> Function(http.Request) respuesta) =>
    MascotaRepository(api: ApiService(client: MockClient(respuesta)));

http.Response _json(Object cuerpo, {Map<String, String> cabeceras = const {}}) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8', ...cabeceras},
    );

final _penita = {
  'id': 1,
  'nombre': 'Peñita',
  'especie': 'Gato',
  'raza': null,
  'edad_meses': 5,
  'descripcion': 'Es muy cariñosa',
  'estado_adopcion': 'Disponible',
  'refugio_id': 2,
  'imagen_url': null,
};

void main() {
  group('Mascota.fromJson', () {
    test('convierte la respuesta de la API (snake_case)', () {
      final m = Mascota.fromJson({
        'id': 1,
        'nombre': 'Turro',
        'especie': 'Perro',
        'raza': 'Criollo',
        'edad_meses': 43,
        'descripcion': 'Muy cariñoso',
        'estado_adopcion': 'Disponible',
        'refugio_id': 1,
        'imagen_url': 'https://res.cloudinary.com/demo/image/upload/a.jpg',
      });
      expect(m.nombre, 'Turro');
      expect(m.edadMeses, 43);
      expect(m.estadoAdopcion, 'Disponible');
      expect(m.imagenUrl, contains('cloudinary'));
    });

    test('acepta campos opcionales en null', () {
      final m = Mascota.fromJson(_penita);
      expect(m.raza, isNull);
      expect(m.imagenUrl, isNull);
    });
  });

  group('Mascota.edadTexto', () {
    Mascota conEdad(int? meses) => Mascota(
        id: 1,
        nombre: 'X',
        especie: 'Perro',
        edadMeses: meses,
        estadoAdopcion: 'Disponible',
        refugioId: 1);

    test('meses, años y combinaciones', () {
      expect(conEdad(1).edadTexto, '1 mes');
      expect(conEdad(2).edadTexto, '2 meses');
      expect(conEdad(12).edadTexto, '1 año');
      expect(conEdad(25).edadTexto, '2 años y 1 mes');
      expect(conEdad(null).edadTexto, 'Edad desconocida');
    });
  });

  group('MascotaRepository', () {
    test('buscar lee la página, respeta tildes y calcula hayMas', () async {
      http.Request? recibida;
      final repo = _repoCon((r) async {
        recibida = r;
        return _json({
          'items': [_penita],
          'total': 25,
          'pagina': 1,
          'por_pagina': 5,
          'paginas': 3,
        });
      });
      final pagina = await repo.buscar(pagina: 1, busqueda: 'criollo', estado: 'Disponible');
      expect(pagina.items.first.nombre, 'Peñita');
      expect(pagina.total, 25);
      expect(pagina.hayMas, isTrue);
      expect(recibida!.url.path, '/mascotas/buscar');
      expect(recibida!.url.queryParameters['raza'], 'criollo');
      expect(recibida!.url.queryParameters['estado'], 'Disponible');
      expect(recibida!.url.queryParameters['pagina'], '1');
    });

    test('la última página no tiene "hayMas"', () async {
      final repo = _repoCon((_) async => _json({
            'items': [_penita],
            'total': 25,
            'pagina': 3,
            'por_pagina': 5,
            'paginas': 3,
          }));
      expect((await repo.buscar(pagina: 3)).hayMas, isFalse);
    });

    test('inventario usa el total de la cabecera X-Total-Count', () async {
      final repo = _repoCon((_) async => _json([_penita], cabeceras: {'x-total-count': '30'}));
      final pagina = await repo.inventario(pagina: 1);
      expect(pagina.total, 30);
      expect(pagina.hayMas, isTrue); // 1 * 5 < 30
    });

    test('un error del servidor lanza ApiException con mensaje', () async {
      final repo = _repoCon((_) async => http.Response('boom', 500));
      expect(
        repo.buscar(pagina: 1),
        throwsA(isA<ApiException>().having((e) => e.mensaje, 'mensaje', contains('500'))),
      );
    });
  });
}
