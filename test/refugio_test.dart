import 'package:flutter_test/flutter_test.dart';
import 'package:paws_shop/models/refugio.dart';

void main() {
  test('Refugio lee la ubicación del mapa (enteros o decimales)', () {
    final r = Refugio.fromJson({'id': 1, 'nombre': 'Patitas', 'latitud': 4.711, 'longitud': -74});
    expect(r.tieneUbicacion, isTrue);
    expect(r.latitud, 4.711);
    expect(r.longitud, -74.0);
  });

  test('Refugio sin ubicación no la tiene', () {
    final r = Refugio.fromJson({'id': 2, 'nombre': 'Sin mapa', 'latitud': null, 'longitud': null});
    expect(r.tieneUbicacion, isFalse);
  });
}
