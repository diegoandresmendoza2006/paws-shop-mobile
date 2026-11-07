import 'package:flutter_test/flutter_test.dart';
import 'package:paws_shop/models/solicitud_adopcion.dart';
import 'package:paws_shop/models/usuario.dart';
import 'package:paws_shop/utils/formato.dart';

void main() {
  group('Usuario.fromJson', () {
    test('lee los datos personales y el rol', () {
      final u = Usuario.fromJson({
        'id': 7,
        'nombre_completo': 'Laura Gómez',
        'email': 'laura@correo.com',
        'rol_id': 3,
        'refugio_id': null,
        'fecha_nacimiento': '1998-05-20',
        'telefono': '3001234567',
        'direccion': 'Calle 10 # 5-20',
      });
      expect(u.esUsuario, isTrue);
      expect(u.rol, 'Usuario');
      expect(u.fechaNacimiento, DateTime(1998, 5, 20));
      expect(u.perfilCompleto, isTrue);
    });

    test('un usuario antiguo sin datos personales tiene el perfil incompleto', () {
      final u = Usuario.fromJson({
        'id': 1,
        'nombre_completo': 'Admin',
        'email': 'admin@pawsshop.com',
        'rol_id': 1,
        'fecha_nacimiento': null,
        'telefono': null,
        'direccion': null,
      });
      expect(u.esAdmin, isTrue);
      expect(u.perfilCompleto, isFalse);
    });
  });

  group('formato', () {
    test('fechaParaApi y fechaLegible', () {
      expect(fechaParaApi(DateTime(2000, 5, 7)), '2000-05-07');
      expect(fechaLegible(DateTime(2000, 5, 7)), '07/05/2000');
    });

    test('fechaMaximaNacimiento es hoy menos 18 años', () {
      expect(fechaMaximaNacimiento(DateTime(2026, 11, 3)), DateTime(2008, 11, 3));
    });

    test('moneda agrega puntos de miles', () {
      expect(moneda(1234567), '\$ 1.234.567');
      expect(moneda(950), '\$ 950');
    });
  });

  group('SolicitudAdopcionNueva.toJson', () {
    SolicitudAdopcionNueva crear({required bool tuvo}) => SolicitudAdopcionNueva(
          mascotaId: 4,
          nombreContacto: 'Laura Gómez',
          fechaNacimiento: DateTime(1998, 5, 20),
          telefono: '3001234567',
          emailContacto: 'laura@correo.com',
          direccion: 'Calle 10 # 5-20',
          tipoVivienda: 'Propia',
          viviendaPermiteMascotas: true,
          tienePatio: true,
          tieneCercas: false,
          personasHogar: 3,
          tuvoMascotas: tuvo,
          mascotasVacunadas: true,
          mascotasEsterilizadas: false,
          horasSolo: 5,
          responsableViajes: 'Mi mamá',
          motivo: '   ',
        );

    test('usa claves snake_case y la fecha en formato de la API', () {
      final json = crear(tuvo: true).toJson();
      expect(json['mascota_id'], 4);
      expect(json['fecha_nacimiento'], '1998-05-20');
      expect(json['mascotas_vacunadas'], true);
    });

    test('si no tuvo mascotas, vacunadas y esterilizadas van en null', () {
      final json = crear(tuvo: false).toJson();
      expect(json['mascotas_vacunadas'], isNull);
      expect(json['mascotas_esterilizadas'], isNull);
    });

    test('un motivo vacío se envía como null', () {
      expect(crear(tuvo: true).toJson()['motivo'], isNull);
    });
  });
}
