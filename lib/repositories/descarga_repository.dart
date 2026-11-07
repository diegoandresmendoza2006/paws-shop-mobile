import '../services/api_service.dart';
import '../utils/api_config.dart';

/// Pide al servidor un enlace temporal (5 minutos) para bajar un archivo: el certificado de
/// adopción en PDF o el reporte de Excel. La app abre ese enlace en el navegador y el archivo se descarga.
class DescargaRepository {
  final ApiService _api;

  DescargaRepository({ApiService? api}) : _api = api ?? ApiService();

  /// GET /adopciones/{id}/certificado/enlace
  Future<String> enlaceCertificado(int solicitudId) async {
    final json = await _api.get('/adopciones/$solicitudId/certificado/enlace');
    return _completo(json);
  }

  /// GET /admin/reporte/enlace  ([mes] = '2026-11'; [historico] = todo el historial)
  Future<String> enlaceReporte({String? mes, bool historico = false}) async {
    final query = <String, String>{};
    if (historico) {
      query['historico'] = 'true';
    } else if (mes != null) {
      query['mes'] = mes;
    }
    final json = await _api.get('/admin/reporte/enlace', query: query);
    return _completo(json);
  }

  String _completo(dynamic json) {
    final ruta = (json as Map<String, dynamic>)['ruta'] as String;
    return '${ApiConfig.baseUrl}$ruta';
  }
}
