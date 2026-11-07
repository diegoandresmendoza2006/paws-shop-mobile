import '../models/usuario.dart';
import '../services/api_service.dart';

/// Los datos del propio usuario: editar información, contraseña y foto de perfil.
class PerfilRepository {
  final ApiService _api;

  PerfilRepository({ApiService? api}) : _api = api ?? ApiService();

  /// PUT /auth/me
  Future<Usuario> actualizar(Map<String, dynamic> datos) async {
    final json = await _api.putJson('/auth/me', datos) as Map<String, dynamic>;
    return Usuario.fromJson(json);
  }

  /// PUT /auth/me/password
  Future<void> cambiarPassword(String actual, String nueva) async {
    await _api.putJson('/auth/me/password', {'actual': actual, 'nueva': nueva});
  }

  /// POST /auth/me/foto (multipart). Si ya había foto, el servidor borra la anterior.
  Future<Usuario> subirFoto(List<int> bytes, String nombre) async {
    final json = await _api.subirArchivo('/auth/me/foto', bytes, nombre)
        as Map<String, dynamic>;
    return Usuario.fromJson(json);
  }

  /// DELETE /auth/me/foto
  Future<Usuario> quitarFoto() async {
    final json = await _api.delete('/auth/me/foto') as Map<String, dynamic>;
    return Usuario.fromJson(json);
  }
}
