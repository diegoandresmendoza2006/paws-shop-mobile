/// Dirección del backend (FastAPI) y tiempos de espera.
///
/// Por defecto apunta al backend desplegado en Render, así funciona en cualquier
/// emulador o celular. Para probar contra tu backend local:
///   flutter run --dart-define=API_URL=http://10.0.2.2:8000     (emulador Android)
///   flutter run --dart-define=API_URL=http://localhost:8000    (Windows / Chrome / iOS simulator)
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://paws-shop-api.onrender.com',
  );

  /// Tiempo máximo de carga: 30 segundos. Si el servidor (Render gratis) estaba dormido, la sonda
  /// de GitHub Actions (.github/workflows/keep-alive.yml) lo despierta a la hora que se configure,
  /// y además la app lo "llama" apenas se abre (ver main.dart) para que ya esté listo al iniciar sesión.
  static const Duration timeout = Duration(seconds: 30);

  /// Cuántos elementos trae cada página (botones «Anterior» / «Siguiente»).
  static const int porPagina = 5;
}
