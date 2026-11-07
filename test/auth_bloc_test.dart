import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paws_shop/bloc/auth_bloc.dart';
import 'package:paws_shop/bloc/auth_event.dart';
import 'package:paws_shop/bloc/auth_state.dart';
import 'package:paws_shop/repositories/auth_repository.dart';
import 'package:paws_shop/services/api_service.dart';

http.Response _json(Object cuerpo, [int codigo = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      codigo,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Map<String, dynamic> _usuario(int id, int rolId) => {
      'id': id,
      'nombre_completo': 'Laura Gómez',
      'email': 'laura@correo.com',
      'rol_id': rolId,
      'fecha_registro': '2026-01-01T00:00:00',
      'fecha_nacimiento': '1998-05-20',
      'telefono': '3101234567',
      'direccion': 'Calle 10 # 5-20',
      'tipo_documento': 'CC',
      'numero_documento': '1012345678',
      'foto_url': null,
    };

const _cuentaEncargado = {'usuario_id': 2, 'rol_id': 2, 'rol': 'Encargado'};
const _cuentaUsuario = {'usuario_id': 9, 'rol_id': 3, 'rol': 'Usuario'};

/// Servidor falso: login (con las cuentas indicadas), /auth/me según el token y cambiar-rol.
AuthBloc _bloc(List<Map<String, dynamic>> cuentas) {
  final cliente = MockClient((r) async {
    switch (r.url.path) {
      case '/auth/login':
        if (r.bodyFields['password'] != 'Clave1234') {
          return _json({'detail': 'Credenciales incorrectas'}, 401);
        }
        return _json({
          'access_token': 'token-${cuentas.first['usuario_id']}',
          'token_type': 'bearer',
          'cuentas': cuentas,
        });
      case '/auth/cambiar-rol':
        final id = (jsonDecode(r.body) as Map<String, dynamic>)['usuario_id'] as int;
        return _json({'access_token': 'token-$id', 'token_type': 'bearer', 'cuentas': cuentas});
      case '/auth/me':
        final id = int.parse(r.headers['Authorization']!.replaceFirst('Bearer token-', ''));
        return _json(_usuario(id, id == 2 ? 2 : 3));
    }
    return http.Response('no encontrado', 404);
  });
  return AuthBloc(AuthRepository(api: ApiService(client: cliente)));
}

void main() {
  test('una sola cuenta: entra directo a la pantalla principal', () async {
    final bloc = _bloc([_cuentaUsuario]);
    bloc.add(const SesionIniciada(email: 'laura@correo.com', password: 'Clave1234'));
    final estado = await bloc.stream.firstWhere((s) => s is AuthAutenticado || s is AuthError);
    expect(estado, isA<AuthAutenticado>());
    expect((estado as AuthAutenticado).sesion.usuario.esUsuario, isTrue);
    await bloc.close();
  });

  test('contraseña incorrecta: AuthError con el mensaje del servidor', () async {
    final bloc = _bloc([_cuentaUsuario]);
    bloc.add(const SesionIniciada(email: 'laura@correo.com', password: 'mala'));
    final estado = await bloc.stream.firstWhere((s) => s is AuthError);
    expect((estado as AuthError).mensaje, 'Credenciales incorrectas');
    await bloc.close();
  });

  test('dos cuentas: pide elegir el rol y luego entra con el elegido', () async {
    final bloc = _bloc([_cuentaEncargado, _cuentaUsuario]);
    bloc.add(const SesionIniciada(email: 'laura@correo.com', password: 'Clave1234'));
    final elegir = await bloc.stream.firstWhere((s) => s is AuthElegirRol);
    expect((elegir as AuthElegirRol).sesion.cuentas, hasLength(2));

    bloc.add(const RolElegido(9)); // quiere entrar como Usuario
    final dentro = await bloc.stream.firstWhere((s) => s is AuthAutenticado);
    expect((dentro as AuthAutenticado).sesion.usuario.esUsuario, isTrue);
    await bloc.close();
  });

  test('elegir la cuenta con la que ya inició no llama al servidor', () async {
    final bloc = _bloc([_cuentaEncargado, _cuentaUsuario]);
    bloc.add(const SesionIniciada(email: 'laura@correo.com', password: 'Clave1234'));
    await bloc.stream.firstWhere((s) => s is AuthElegirRol);
    bloc.add(const RolElegido(2)); // la cuenta de Encargado (la de más privilegio)
    final dentro = await bloc.stream.firstWhere((s) => s is AuthAutenticado);
    expect((dentro as AuthAutenticado).sesion.usuario.esEncargado, isTrue);
    await bloc.close();
  });

  test('cerrar sesión vuelve al estado inicial', () async {
    final bloc = _bloc([_cuentaUsuario]);
    bloc.add(const SesionIniciada(email: 'laura@correo.com', password: 'Clave1234'));
    await bloc.stream.firstWhere((s) => s is AuthAutenticado);
    bloc.add(const SesionCerrada());
    expect(await bloc.stream.firstWhere((s) => s is AuthInicial), isA<AuthInicial>());
    await bloc.close();
  });
}
