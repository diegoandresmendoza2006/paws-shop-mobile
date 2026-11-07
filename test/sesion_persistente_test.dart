import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paws_shop/bloc/auth_bloc.dart';
import 'package:paws_shop/bloc/auth_event.dart';
import 'package:paws_shop/bloc/auth_state.dart';
import 'package:paws_shop/repositories/auth_repository.dart';
import 'package:paws_shop/repositories/sesion_local_repository.dart';
import 'package:paws_shop/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object cuerpo, [int codigo = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      codigo,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _usuario = {
  'id': 3,
  'nombre_completo': 'Laura Gómez',
  'email': 'laura@correo.com',
  'rol_id': 3,
  'fecha_registro': '2026-01-01T00:00:00',
  'fecha_nacimiento': '1998-05-20',
  'telefono': '3101234567',
  'direccion': 'Calle 10 # 5-20',
  'tipo_documento': 'CC',
  'numero_documento': '1012345678',
  'foto_url': null,
};
const _cuenta = {'usuario_id': 3, 'rol_id': 3, 'rol': 'Usuario'};

/// Servidor falso. [tokenValido] es el único token que acepta /auth/me.
AuthRepository _repo({String tokenValido = 'token-3'}) {
  final cliente = MockClient((r) async {
    switch (r.url.path) {
      case '/auth/login':
        return _json({'access_token': 'token-3', 'token_type': 'bearer', 'cuentas': [_cuenta]});
      case '/auth/me':
        if (r.headers['Authorization'] != 'Bearer $tokenValido') {
          return _json({'detail': 'Token inválido'}, 401);
        }
        return _json(_usuario);
      case '/auth/cuentas':
        return _json([_cuenta]);
    }
    return http.Response('no encontrado', 404);
  });
  return AuthRepository(api: ApiService(client: cliente), local: SesionLocalRepository());
}

AuthBloc _bloc(AuthRepository repo) => AuthBloc(repo, restaurar: true);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('al abrir la app sin sesión guardada se ve el login', () async {
    final bloc = _bloc(_repo());
    expect(bloc.state, isA<AuthRestaurando>());
    bloc.add(const SesionRestaurada());
    expect(await bloc.stream.first, isA<AuthInicial>());
    await bloc.close();
  });

  test('iniciar sesión la recuerda: la próxima vez entra directo', () async {
    final primera = AuthBloc(_repo());
    primera.add(const SesionIniciada(email: 'laura@correo.com', password: 'Clave#Segura9'));
    await primera.stream.firstWhere((s) => s is AuthAutenticado);
    await primera.close();

    final segunda = _bloc(_repo()); // "se cerró y se volvió a abrir la app"
    segunda.add(const SesionRestaurada());
    final estado = await segunda.stream.first;
    expect(estado, isA<AuthAutenticado>());
    expect((estado as AuthAutenticado).sesion.usuario.nombreCompleto, 'Laura Gómez');
    await segunda.close();
  });

  test('cerrar sesión la olvida', () async {
    final bloc = AuthBloc(_repo());
    bloc.add(const SesionIniciada(email: 'laura@correo.com', password: 'Clave#Segura9'));
    await bloc.stream.firstWhere((s) => s is AuthAutenticado);
    bloc.add(const SesionCerrada());
    await bloc.stream.firstWhere((s) => s is AuthInicial);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await bloc.close();

    expect(await SesionLocalRepository().leerToken(), isNull);
  });

  test('un token vencido se descarta y se pide iniciar sesión', () async {
    SharedPreferences.setMockInitialValues({'token_sesion': 'token-viejo'});
    final bloc = _bloc(_repo()); // el servidor solo acepta token-3
    bloc.add(const SesionRestaurada());
    expect(await bloc.stream.first, isA<AuthInicial>());
    expect(await SesionLocalRepository().leerToken(), isNull);
    await bloc.close();
  });
}
