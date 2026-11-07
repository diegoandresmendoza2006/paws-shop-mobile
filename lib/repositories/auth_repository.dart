import '../models/cuenta.dart';
import '../models/sesion.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import 'sesion_local_repository.dart';

/// Inicio de sesión, registro y cambio de rol.
class AuthRepository {
  final ApiService _api;
  final SesionLocalRepository _local;

  AuthRepository({ApiService? api, SesionLocalRepository? local})
      : _api = api ?? ApiService(),
        _local = local ?? SesionLocalRepository();

  /// Al abrir la app: si quedó una sesión guardada y el servidor todavía la acepta, la recupera.
  /// Si no hay nada guardado, o el token venció, devuelve null (se muestra el login).
  Future<Sesion?> restaurarSesion() async {
    final token = await _local.leerToken();
    if (token == null || token.isEmpty) return null;
    _api.token = token;
    try {
      final yo = await _api.get('/auth/me') as Map<String, dynamic>;
      final lista = await _api.get('/auth/cuentas') as List<dynamic>;
      final cuentas =
          lista.map((e) => Cuenta.fromJson(e as Map<String, dynamic>)).toList();
      return Sesion(token: token, usuario: Usuario.fromJson(yo), cuentas: cuentas);
    } on ApiException catch (e) {
      // Token vencido o inválido (401/403): se descarta. Sin internet (otro error): también se
      // pide iniciar sesión, pero el token se conserva para la próxima vez.
      if (e.codigo == 401 || e.codigo == 403) await _local.borrar();
      _api.token = null;
      return null;
    } catch (_) {
      _api.token = null;
      return null;
    }
  }

  /// POST /auth/login (formulario) y luego GET /auth/me.
  /// Si la persona tiene dos cuentas (p. ej. Encargado y Usuario), vienen las dos en [Sesion.cuentas].
  Future<Sesion> iniciarSesion(String email, String password) async {
    final json = await _api.postForm('/auth/login', {
      'username': email.trim(),
      'password': password,
    }) as Map<String, dynamic>;
    return _armarSesion(json);
  }

  /// POST /auth/registro (JSON) y luego inicia sesión automáticamente.
  Future<Sesion> registrar({
    required String nombreCompleto,
    required String email,
    required String password,
    required String tipoDocumento,
    required String numeroDocumento,
    required String fechaNacimiento, // yyyy-mm-dd
    required String telefono,
    required String direccion,
  }) async {
    await _api.postJson('/auth/registro', {
      'nombre_completo': nombreCompleto.trim(),
      'email': email.trim(),
      'password': password,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento.trim(),
      'fecha_nacimiento': fechaNacimiento,
      'telefono': telefono,
      'direccion': direccion.trim(),
    });
    return iniciarSesion(email, password);
  }

  /// POST /auth/cambiar-rol: entra con otra de tus cuentas sin volver a escribir la contraseña.
  Future<Sesion> cambiarRol(int usuarioId) async {
    final json = await _api.postJson(
        '/auth/cambiar-rol', {'usuario_id': usuarioId}) as Map<String, dynamic>;
    return _armarSesion(json);
  }

  void cerrarSesion() {
    _api.token = null;
    _local.borrar(); // ya no se recuerda: la próxima vez hay que iniciar sesión
  }

  Future<Sesion> _armarSesion(Map<String, dynamic> json) async {
    final token = json['access_token'] as String;
    _api.token = token; // desde aquí todas las peticiones llevan el token
    await _local.guardarToken(token);
    final yo = await _api.get('/auth/me') as Map<String, dynamic>;
    final cuentas = ((json['cuentas'] as List<dynamic>?) ?? [])
        .map((e) => Cuenta.fromJson(e as Map<String, dynamic>))
        .toList();
    return Sesion(token: token, usuario: Usuario.fromJson(yo), cuentas: cuentas);
  }
}
