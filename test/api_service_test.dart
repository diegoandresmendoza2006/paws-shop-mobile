import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paws_shop/services/api_service.dart';

http.Response _json(Object cuerpo, int codigo) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      codigo,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  test('manda el token en la cabecera Authorization', () async {
    String? cabecera;
    final api = ApiService(client: MockClient((r) async {
      cabecera = r.headers['Authorization'];
      return _json({'ok': true}, 200);
    }));
    api.token = 'abc';
    await api.get('/auth/me');
    expect(cabecera, 'Bearer abc');
  });

  test('un error 422 de validación se convierte en texto legible', () async {
    final api = ApiService(client: MockClient((_) async => _json({
          'detail': [
            {'loc': ['body', 'telefono'], 'msg': 'Value error, Teléfono inválido'},
            {'loc': ['body', 'direccion'], 'msg': 'Dirección muy corta'},
          ]
        }, 422)));
    expect(
      api.postJson('/auth/registro', {}),
      throwsA(isA<ApiException>().having(
          (e) => e.mensaje, 'mensaje', 'Teléfono inválido\nDirección muy corta')),
    );
  });

  test('un detail de texto se muestra tal cual', () async {
    final api = ApiService(
        client: MockClient((_) async => _json({'detail': 'El correo ya está registrado'}, 400)));
    expect(
      api.postJson('/auth/registro', {}),
      throwsA(isA<ApiException>()
          .having((e) => e.mensaje, 'mensaje', 'El correo ya está registrado')),
    );
  });

  test('un 401 con sesión abierta avisa que la sesión expiró', () async {
    var avisado = false;
    final api = ApiService(client: MockClient((_) async => _json({'detail': 'x'}, 401)));
    api.token = 'viejo';
    api.alExpirarSesion = () => avisado = true;
    await expectLater(api.get('/mascotas/'), throwsA(isA<ApiException>()));
    expect(avisado, isTrue);
  });

  test('lee el total de la cabecera X-Total-Count', () async {
    final api = ApiService(client: MockClient((_) async => http.Response.bytes(
          utf8.encode('[]'),
          200,
          headers: {'content-type': 'application/json', 'x-total-count': '42'},
        )));
    final r = await api.getConTotal('/adopciones/');
    expect(r.total, 42);
    expect(r.datos, isEmpty);
  });

  test('una respuesta 204 (sin cuerpo) no falla', () async {
    final api = ApiService(client: MockClient((_) async => http.Response('', 204)));
    expect(await api.delete('/favoritos/mascotas/1'), isNull);
  });

  test('sube un archivo como multipart en el campo "archivo"', () async {
    String? tipo;
    final api = ApiService(client: MockClient((r) async {
      tipo = r.headers['content-type'];
      return _json({'id': 1}, 200);
    }));
    await api.subirArchivo('/auth/me/foto', [1, 2, 3], 'foto.png');
    expect(tipo, startsWith('multipart/form-data'));
  });
}
