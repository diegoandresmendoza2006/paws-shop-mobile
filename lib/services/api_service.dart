import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';

/// Error "con mensaje listo para mostrar al usuario".
class ApiException implements Exception {
  final String mensaje;
  final int? codigo;
  const ApiException(this.mensaje, [this.codigo]);

  @override
  String toString() => mensaje;
}

/// Lo que devuelve una petición: el JSON ya decodificado y, si el servidor lo manda,
/// el total de filas (cabecera X-Total-Count, la usan las listas paginadas).
class RespuestaApi {
  final dynamic datos;
  final int? total;
  const RespuestaApi(this.datos, this.total);
}

/// ÚNICO lugar de toda la app donde se hace una petición HTTP.
/// Pone el token, controla el tiempo de espera (30 s) y convierte los errores en mensajes legibles.
class ApiService {
  final http.Client _client;

  /// Token JWT de la sesión. Lo pone el AuthRepository al iniciar sesión.
  String? token;

  /// Se llama cuando el servidor dice 401 con una sesión abierta (token vencido).
  void Function()? alExpirarSesion;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ---------------- métodos públicos ----------------
  Future<dynamic> get(String ruta, {Map<String, String>? query}) async =>
      (await _enviar('GET', ruta, query: query)).datos;

  Future<RespuestaApi> getConTotal(String ruta,
          {Map<String, String>? query}) =>
      _enviar('GET', ruta, query: query);

  Future<dynamic> postJson(String ruta, Map<String, dynamic> cuerpo) async =>
      (await _enviar('POST', ruta, cuerpoJson: cuerpo)).datos;

  /// Formulario clásico (application/x-www-form-urlencoded): lo usa el login de FastAPI.
  Future<dynamic> postForm(String ruta, Map<String, String> campos) async =>
      (await _enviar('POST', ruta, formulario: campos)).datos;

  Future<dynamic> putJson(String ruta, Map<String, dynamic> cuerpo) async =>
      (await _enviar('PUT', ruta, cuerpoJson: cuerpo)).datos;

  Future<dynamic> patchJson(String ruta, Map<String, dynamic> cuerpo) async =>
      (await _enviar('PATCH', ruta, cuerpoJson: cuerpo)).datos;

  Future<dynamic> put(String ruta) async =>
      (await _enviar('PUT', ruta)).datos;

  Future<dynamic> delete(String ruta, {Map<String, String>? query}) async =>
      (await _enviar('DELETE', ruta, query: query)).datos;

  /// Sube un archivo (foto) como multipart/form-data en el campo "archivo".
  /// [campos] = otros campos de texto del mismo formulario (por ejemplo el tipo de imagen).
  Future<dynamic> subirArchivo(String ruta, List<int> bytes, String nombre,
          {Map<String, String>? campos}) async =>
      (await _enviar('POST', ruta, archivo: bytes, nombreArchivo: nombre, camposArchivo: campos))
          .datos;

  // ---------------- internos ----------------
  Uri _uri(String ruta, Map<String, String>? query) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$ruta');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  Future<RespuestaApi> _enviar(
    String metodo,
    String ruta, {
    Map<String, String>? query,
    Object? cuerpoJson,
    Map<String, String>? formulario,
    List<int>? archivo,
    String? nombreArchivo,
    Map<String, String>? camposArchivo,
  }) async {
    final uri = _uri(ruta, query);
    final cabeceras = <String, String>{'Accept': 'application/json'};
    final t = token;
    if (t != null) cabeceras['Authorization'] = 'Bearer $t';

    late http.Response respuesta;
    try {
      late http.BaseRequest peticion;
      if (archivo != null) {
        final multipart = http.MultipartRequest(metodo, uri)
          ..headers.addAll(cabeceras)
          ..fields.addAll(camposArchivo ?? const <String, String>{})
          ..files.add(http.MultipartFile.fromBytes('archivo', archivo,
              filename: nombreArchivo ?? 'foto.jpg'));
        peticion = multipart;
      } else {
        final normal = http.Request(metodo, uri)..headers.addAll(cabeceras);
        if (cuerpoJson != null) {
          normal.headers['Content-Type'] = 'application/json; charset=utf-8';
          normal.body = jsonEncode(cuerpoJson);
        } else if (formulario != null) {
          normal.bodyFields = formulario;
        }
        peticion = normal;
      }
      final flujo = await _client.send(peticion).timeout(ApiConfig.timeout);
      respuesta = await http.Response.fromStream(flujo);
    } on TimeoutException {
      throw const ApiException(
          'El servidor tardó más de 30 segundos en responder. Puede estar despertando: intenta de nuevo.');
    } catch (_) {
      throw const ApiException(
          'No se pudo conectar con el servidor. Revisa tu conexión a internet.');
    }

    if (respuesta.statusCode >= 400) {
      if (respuesta.statusCode == 401 && t != null) {
        alExpirarSesion?.call();
        throw ApiException(
            'Tu sesión expiró. Inicia sesión de nuevo.', respuesta.statusCode);
      }
      throw ApiException(_mensajeDeError(respuesta), respuesta.statusCode);
    }

    dynamic datos;
    if (respuesta.bodyBytes.isNotEmpty) {
      try {
        datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      } catch (_) {
        datos = null;
      }
    }
    final total = int.tryParse(respuesta.headers['x-total-count'] ?? '');
    return RespuestaApi(datos, total);
  }

  /// FastAPI manda el error en "detail": un texto, o una lista cuando falla la validación (422).
  String _mensajeDeError(http.Response r) {
    try {
      final cuerpo = jsonDecode(utf8.decode(r.bodyBytes));
      if (cuerpo is Map && cuerpo['detail'] != null) {
        final detalle = cuerpo['detail'];
        if (detalle is String) return detalle;
        if (detalle is List && detalle.isNotEmpty) {
          return detalle
              .map((e) => e is Map
                  ? (e['msg'] ?? 'Dato inválido').toString().replaceFirst('Value error, ', '')
                  : e.toString())
              .join('\n');
        }
      }
    } catch (_) {
      // el cuerpo no era JSON: caemos al mensaje genérico
    }
    return 'El servidor respondió con un error (${r.statusCode}).';
  }

  void cerrar() => _client.close();
}
