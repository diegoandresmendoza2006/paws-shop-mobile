// Reglas de validación de los formularios (las mismas que aplica el backend, para avisar ANTES de enviar).

String? validarObligatorio(String? v, {int min = 1, String nombre = 'Este campo'}) {
  final texto = (v ?? '').trim();
  if (texto.isEmpty) return '$nombre es obligatorio';
  if (texto.length < min) return '$nombre debe tener al menos $min caracteres';
  return null;
}

String? validarEmail(String? v) {
  final texto = (v ?? '').trim();
  if (texto.isEmpty) return 'El correo es obligatorio';
  final valido = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(texto);
  return valido ? null : 'Escribe un correo válido (ej: nombre@correo.com)';
}

/// Una regla de la contraseña y si ya se cumple (la misma lista que exige el servidor).
class RequisitoClave {
  final String texto;
  final bool cumple;
  const RequisitoClave(this.texto, this.cumple);
}

/// ¿Tiene tres números pegados en secuencia? (123, 456, 321, 987...)
bool tieneNumerosEnSecuencia(String texto) {
  for (var i = 0; i + 2 < texto.length; i++) {
    final a = int.tryParse(texto[i]);
    final b = int.tryParse(texto[i + 1]);
    final c = int.tryParse(texto[i + 2]);
    if (a == null || b == null || c == null) continue;
    if ((b - a == 1 && c - b == 1) || (b - a == -1 && c - b == -1)) return true;
  }
  return false;
}

/// Las 4 reglas de la contraseña, con cuáles ya cumple lo escrito.
/// Con el campo vacío ninguna aparece como cumplida.
List<RequisitoClave> requisitosDeClave(String texto) => [
      RequisitoClave('Mínimo 8 caracteres', texto.length >= 8),
      RequisitoClave('Una letra mayúscula', texto.runes.any((r) {
        final c = String.fromCharCode(r);
        return c != c.toLowerCase() && c == c.toUpperCase();
      })),
      RequisitoClave('Un carácter especial (! @ # \$ %)', texto.runes.any((r) {
        final c = String.fromCharCode(r);
        return c.trim().isNotEmpty && RegExp(r'[^\p{L}\p{N}]', unicode: true).hasMatch(c);
      })),
      RequisitoClave('Sin números en secuencia (123, 321)', texto.isNotEmpty && !tieneNumerosEnSecuencia(texto)),
    ];

String? validarPassword(String? v) {
  final texto = v ?? '';
  if (texto.isEmpty) return 'La contraseña es obligatoria';
  if (texto.length > 72) return 'No puede pasar de 72 caracteres';
  final faltan = requisitosDeClave(texto).where((r) => !r.cumple).map((r) => r.texto.toLowerCase());
  return faltan.isEmpty ? null : 'Falta: ${faltan.join(', ')}';
}

/// Celular colombiano: 10 dígitos que empiezan por 3 (ej: 310 123 4567).
String? validarTelefono(String? v) {
  final texto = (v ?? '').replaceAll(' ', '');
  if (texto.isEmpty) return 'El teléfono es obligatorio';
  if (!RegExp(r'^3\d{9}$').hasMatch(texto)) {
    return 'Escribe 10 dígitos que empiecen por 3 (ej: 310 123 4567)';
  }
  return null;
}

/// CC y CE: solo números (6 a 12). Pasaporte: letras y números (5 a 20).
String? validarDocumento(String tipo, String? v) {
  final texto = (v ?? '').trim();
  if (texto.isEmpty) return 'El número de documento es obligatorio';
  if (tipo == 'PAS') {
    return RegExp(r'^[A-Za-z0-9]{5,20}$').hasMatch(texto)
        ? null
        : 'Pasaporte: de 5 a 20 letras o números';
  }
  return RegExp(r'^\d{6,12}$').hasMatch(texto)
      ? null
      : 'Escribe solo números (de 6 a 12 dígitos)';
}

/// Número entero entre [min] y [max].
String? validarEntero(String? v, {required int min, required int max, String nombre = 'El valor'}) {
  final n = int.tryParse((v ?? '').trim());
  if (n == null) return '$nombre debe ser un número';
  if (n < min || n > max) return '$nombre debe estar entre $min y $max';
  return null;
}

/// Precio: un número mayor que 0 (acepta coma o punto como separador decimal).
String? validarPrecio(String? v) {
  final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
  if (n == null) return 'El precio debe ser un número';
  if (n <= 0) return 'El precio debe ser mayor que 0';
  return null;
}

/// Texto opcional con un máximo de caracteres.
String? validarMaximo(String? v, int max, {String nombre = 'Este campo'}) {
  if ((v ?? '').trim().length > max) return '$nombre no puede pasar de $max caracteres';
  return null;
}

/// Convierte un texto vacío en null (para no mandar "" a la API).
String? vacioANulo(String? v) {
  final texto = (v ?? '').trim();
  return texto.isEmpty ? null : texto;
}
