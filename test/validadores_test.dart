import 'package:flutter_test/flutter_test.dart';
import 'package:paws_shop/utils/validadores.dart';

void main() {
  group('validarTelefono (celular colombiano)', () {
    test('acepta 10 dígitos que empiezan por 3', () {
      expect(validarTelefono('3101234567'), isNull);
      expect(validarTelefono('310 123 4567'), isNull);
    });
    test('rechaza vacío, muy corto o que no empieza por 3', () {
      expect(validarTelefono(''), isNotNull);
      expect(validarTelefono('310123'), isNotNull);
      expect(validarTelefono('2101234567'), isNotNull);
    });
  });

  group('validarDocumento', () {
    test('CC y CE: solo números de 6 a 12', () {
      expect(validarDocumento('CC', '1012345678'), isNull);
      expect(validarDocumento('CE', '123456'), isNull);
      expect(validarDocumento('CC', '12'), isNotNull);
      expect(validarDocumento('CC', 'AB123456'), isNotNull);
    });
    test('Pasaporte: letras y números', () {
      expect(validarDocumento('PAS', 'AB123456'), isNull);
      expect(validarDocumento('PAS', 'AB1'), isNotNull);
    });
  });

  test('validarEmail', () {
    expect(validarEmail('ana@correo.com'), isNull);
    expect(validarEmail('ana@correo'), isNotNull);
    expect(validarEmail(''), isNotNull);
  });

  test('validarPassword exige 8 caracteres, mayúscula, especial y sin secuencias', () {
    expect(validarPassword('Clave#Segura9'), isNull);
    expect(validarPassword('Clave#1a2b3c'), isNull); // números separados no son secuencia
    expect(validarPassword('corta'), isNotNull);
    expect(validarPassword('clave#segura9'), contains('mayúscula'));
    expect(validarPassword('ClaveSegura9'), contains('especial'));
    expect(validarPassword('Clave#1234'), contains('secuencia'));
    expect(validarPassword('Clave#987x'), contains('secuencia'));
    expect(validarPassword(''), 'La contraseña es obligatoria');
  });

  test('requisitosDeClave marca los que va cumpliendo', () {
    bool cumple(String clave, int i) => requisitosDeClave(clave)[i].cumple;
    expect(requisitosDeClave('').every((r) => !r.cumple), isTrue); // vacía: ninguno
    expect(cumple('Abcdefgh', 0), isTrue);
    expect(cumple('Abc', 0), isFalse);
    expect(cumple('abc', 1), isFalse);
    expect(cumple('Abc', 1), isTrue);
    expect(cumple('Abc!', 2), isTrue);
    expect(cumple('Abc1', 2), isFalse);
    expect(cumple('Abc123', 3), isFalse);
    expect(cumple('Abc135', 3), isTrue);
  });

  test('tieneNumerosEnSecuencia', () {
    expect(tieneNumerosEnSecuencia('x123'), isTrue);
    expect(tieneNumerosEnSecuencia('x321'), isTrue);
    expect(tieneNumerosEnSecuencia('x12y3'), isFalse);
    expect(tieneNumerosEnSecuencia('x124'), isFalse);
  });

  test('validarEntero', () {
    expect(validarEntero('3', min: 1, max: 30), isNull);
    expect(validarEntero('0', min: 1, max: 30), isNotNull);
    expect(validarEntero('abc', min: 1, max: 30), isNotNull);
  });
}
