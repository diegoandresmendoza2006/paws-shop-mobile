import '../models/foto_nueva.dart';
import '../services/api_service.dart';

/// Sube las fotos de mascotas y productos a Cloudinary (a través del backend).
class ImagenRepository {
  final ApiService _api;

  ImagenRepository({ApiService? api}) : _api = api ?? ApiService();

  /// POST /imagenes/  -> devuelve la dirección (URL) de la foto ya subida.
  /// [tipo] = 'mascotas' o 'productos'. [subcarpeta] = raza o categoría; [especie] solo en mascotas.
  Future<String> subir(
    FotoNueva foto, {
    required String tipo,
    String subcarpeta = '',
    String especie = '',
  }) async {
    final json = await _api.subirArchivo(
      '/imagenes/',
      foto.bytes,
      foto.nombre,
      campos: {'tipo': tipo, 'subcarpeta': subcarpeta, 'especie': especie},
    ) as Map<String, dynamic>;
    return json['url'] as String;
  }

  /// DELETE /imagenes/?url=...  Borra una foto subida que al final no se guardó.
  Future<void> descartar(String url) async {
    await _api.delete('/imagenes/', query: {'url': url});
  }
}
