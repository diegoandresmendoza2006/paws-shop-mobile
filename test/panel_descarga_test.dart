import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paws_shop/bloc/descarga_bloc.dart';
import 'package:paws_shop/bloc/descarga_event.dart';
import 'package:paws_shop/bloc/descarga_state.dart';
import 'package:paws_shop/bloc/panel_bloc.dart';
import 'package:paws_shop/bloc/panel_event.dart';
import 'package:paws_shop/bloc/panel_state.dart';
import 'package:paws_shop/repositories/admin_repository.dart';
import 'package:paws_shop/repositories/descarga_repository.dart';
import 'package:paws_shop/services/api_service.dart';
import 'package:paws_shop/utils/formato.dart';

http.Response _json(Object cuerpo, [int codigo = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      codigo,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Map<String, dynamic> _metricas(String mes, {int solicitudes = 0, double ventas = 0}) => {
      'mes': mes,
      'solicitudes_mes': solicitudes,
      'adopciones_mes': 0,
      'pedidos_mes': 0,
      'ventas_mes': ventas,
      'ventas_totales': 150.0,
      'usuarios_registrados': 9,
      'usuarios_nuevos_mes': 1,
      'mascotas_disponibles': 4,
      'mascotas_adoptadas': 2,
    };

Map<String, dynamic> _mes(String mes, String nombre, int solicitudes, double ventas) => {
      'mes': mes,
      'nombre': nombre,
      'solicitudes': solicitudes,
      'adopciones': 1,
      'pedidos': 2,
      'ventas': ventas,
      'usuarios_nuevos': 3,
    };

AdminRepository _admin(List<String> pedidos) => AdminRepository(
      api: ApiService(client: MockClient((r) async {
        pedidos.add('${r.url.path}?${r.url.query}');
        if (r.url.path == '/admin/metricas/meses') {
          return _json([_mes('2026-10', 'Octubre 2026', 5, 100), _mes('2026-11', 'Noviembre 2026', 2, 50)]);
        }
        final mes = r.url.queryParameters['mes'] ?? '2026-11';
        return _json(_metricas(mes, solicitudes: mes == '2026-10' ? 5 : 2, ventas: mes == '2026-10' ? 100 : 50));
      })),
    );

void main() {
  group('PanelBloc (dashboard por meses)', () {
    test('al abrir muestra el mes actual y el historial', () async {
      final bloc = PanelBloc(_admin([]))..add(const PanelSolicitado());
      final estado = await bloc.stream.firstWhere((s) => s is PanelCargado) as PanelCargado;
      expect(estado.periodo, '2026-11');
      expect(estado.titulo, 'Noviembre 2026');
      expect(estado.historial.length, 2);
      expect(estado.solicitudes, 2);
      await bloc.close();
    });

    test('elegir otro mes pide solo ese mes', () async {
      final pedidos = <String>[];
      final bloc = PanelBloc(_admin(pedidos))..add(const PanelSolicitado());
      await bloc.stream.firstWhere((s) => s is PanelCargado);
      bloc.add(const PanelPeriodoElegido('2026-10'));
      final estado = await bloc.stream
          .firstWhere((s) => s is PanelCargado && !s.cambiandoPeriodo && s.periodo == '2026-10') as PanelCargado;
      expect(estado.solicitudes, 5);
      expect(estado.ventas, 100);
      expect(pedidos.last, contains('mes=2026-10'));
      await bloc.close();
    });

    test('todo el historial suma los meses sin pedir nada más', () async {
      final pedidos = <String>[];
      final bloc = PanelBloc(_admin(pedidos))..add(const PanelSolicitado());
      await bloc.stream.firstWhere((s) => s is PanelCargado);
      final antes = pedidos.length;
      bloc.add(const PanelPeriodoElegido(PanelBloc.todoElHistorial));
      final estado = await bloc.stream.firstWhere((s) => s is PanelCargado && s.esHistorico) as PanelCargado;
      expect(estado.solicitudes, 7);
      expect(estado.ventas, 150);
      expect(estado.adopciones, 2);
      expect(estado.usuariosNuevos, 6);
      expect(estado.titulo, 'Todo el historial');
      expect(pedidos.length, antes);
      await bloc.close();
    });

    test('un error del servidor se muestra con su mensaje', () async {
      final repo = AdminRepository(
          api: ApiService(client: MockClient((_) async => _json({'detail': 'Sin permiso'}, 403))));
      final bloc = PanelBloc(repo)..add(const PanelSolicitado());
      final error = await bloc.stream.firstWhere((s) => s is PanelError) as PanelError;
      expect(error.mensaje, 'Sin permiso');
      await bloc.close();
    });
  });

  group('Descargas', () {
    DescargaRepository repo(List<http.Request> vistos) => DescargaRepository(
          api: ApiService(client: MockClient((r) async {
            vistos.add(r);
            return _json({'ruta': '/descargas/x?t=abc', 'expira_en': 300});
          })),
        );

    test('el certificado pide el enlace de esa adopción y arma la URL completa', () async {
      final vistos = <http.Request>[];
      final url = await repo(vistos).enlaceCertificado(7);
      expect(vistos.single.url.path, '/adopciones/7/certificado/enlace');
      expect(url.endsWith('/descargas/x?t=abc'), isTrue);
      expect(url.startsWith('http'), isTrue);
    });

    test('el reporte manda el mes o el historial', () async {
      final vistos = <http.Request>[];
      final r = repo(vistos);
      await r.enlaceReporte(mes: '2026-11');
      await r.enlaceReporte(historico: true);
      expect(vistos[0].url.queryParameters, {'mes': '2026-11'});
      expect(vistos[1].url.queryParameters, {'historico': 'true'});
    });

    test('DescargaBloc entrega el enlace o el error', () async {
      final bloc = DescargaBloc(repo([]))..add(const CertificadoPedido(3));
      final lista = await bloc.stream.firstWhere((s) => s is DescargaLista) as DescargaLista;
      expect(lista.url, contains('/descargas/x'));
      await bloc.close();

      final malo = DescargaBloc(DescargaRepository(
          api: ApiService(client: MockClient((_) async => _json({'detail': 'Solo aprobadas'}, 400)))))
        ..add(const CertificadoPedido(3));
      final error = await malo.stream.firstWhere((s) => s is DescargaError) as DescargaError;
      expect(error.mensaje, 'Solo aprobadas');
      await malo.close();
    });
  });

  group('Nombres de mes', () {
    test('nombreDeMes y mesCorto', () {
      expect(nombreDeMes('2026-11'), 'Noviembre 2026');
      expect(mesCorto('2026-12'), 'Dic 2026');
      expect(nombreDeMes('basura'), 'basura');
    });
  });
}
