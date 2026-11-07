import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paws_shop/bloc/gestion_bloc.dart';
import 'package:paws_shop/bloc/gestion_event.dart';
import 'package:paws_shop/bloc/gestion_state.dart';
import 'package:paws_shop/repositories/admin_repository.dart';
import 'package:paws_shop/repositories/mascota_repository.dart';
import 'package:paws_shop/repositories/producto_repository.dart';
import 'package:paws_shop/repositories/refugio_repository.dart';
import 'package:paws_shop/repositories/solicitud_repository.dart';
import 'package:paws_shop/services/api_service.dart';

GestionBloc _bloc(Future<http.Response> Function(http.Request) respuesta) {
  final api = ApiService(client: MockClient(respuesta));
  return GestionBloc(
    admin: AdminRepository(api: api),
    solicitudes: SolicitudRepository(api: api),
    mascotas: MascotaRepository(api: api),
    productos: ProductoRepository(api: api),
    refugios: RefugioRepository(api: api),
  );
}

http.Response _error(int codigo, String detalle) => http.Response.bytes(
    utf8.encode(jsonEncode({'detail': detalle})), codigo,
    headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  test('eliminar un cliente con historial pide confirmar y luego borra todo con forzar=true', () async {
    final pedidos = <String>[];
    final bloc = _bloc((r) async {
      pedidos.add('${r.method} ${r.url.path}?${r.url.query}');
      return r.url.queryParameters['forzar'] == 'true'
          ? http.Response('', 204)
          : _error(409, 'Este cliente tiene solicitudes de adopción o compras registradas');
    });

    bloc.add(const ClienteEliminado(7));
    final conflicto = await bloc.stream.firstWhere((s) => s is GestionConflicto) as GestionConflicto;
    expect(conflicto.mensaje, contains('tiene solicitudes'));
    final forzado = conflicto.eventoForzado as ClienteEliminado;
    expect(forzado.id, 7);
    expect(forzado.forzar, isTrue);

    bloc.add(forzado); // el administrador aceptó la segunda pregunta
    final exito = await bloc.stream.firstWhere((s) => s is GestionExitosa) as GestionExitosa;
    expect(exito.mensaje, 'Cliente eliminado');
    expect(pedidos, ['DELETE /admin/clientes/7?', 'DELETE /admin/clientes/7?forzar=true']);
    await bloc.close();
  });

  test('un error que no es 409 sigue siendo un error normal', () async {
    final bloc = _bloc((_) async => _error(404, 'El encargado no existe'));
    bloc.add(const EncargadoEliminado(3));
    final error = await bloc.stream.firstWhere((s) => s is GestionError) as GestionError;
    expect(error.mensaje, 'El encargado no existe');
    await bloc.close();
  });

  test('el encargado sin historial se elimina de una vez', () async {
    final bloc = _bloc((_) async => http.Response('', 204));
    bloc.add(const EncargadoEliminado(3));
    final exito = await bloc.stream.firstWhere((s) => s is GestionExitosa) as GestionExitosa;
    expect(exito.mensaje, 'Encargado eliminado');
    await bloc.close();
  });
}
