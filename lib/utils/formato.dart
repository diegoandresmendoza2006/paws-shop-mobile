// Funciones pequeñas para dar formato a fechas y dinero.

/// 2000-05-07  (el formato que espera la API)
String fechaParaApi(DateTime f) =>
    '${f.year.toString().padLeft(4, '0')}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}';

/// 07/05/2000  (lo que ve el usuario)
String fechaLegible(DateTime f) =>
    '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

/// 07/05/2000 14:30
String fechaHoraLegible(DateTime f) =>
    '${fechaLegible(f)} ${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

/// La fecha de nacimiento más reciente permitida: hoy menos 18 años.
DateTime fechaMaximaNacimiento([DateTime? hoy]) {
  final h = hoy ?? DateTime.now();
  return DateTime(h.year - 18, h.month, h.day);
}

/// 1234567 -> "$ 1.234.567"
String moneda(num valor) {
  final entero = valor.round().toString();
  final conPuntos = entero.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '\$ $conPuntos';
}

/// Convierte "2026-05-07T14:30:00" (o null) en DateTime? sin lanzar errores.
DateTime? fechaDeApi(Object? valor) =>
    valor is String ? DateTime.tryParse(valor) : null;

const _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

/// "2026-11" -> "Noviembre 2026"
String nombreDeMes(String aaaaMm) {
  final partes = aaaaMm.split('-');
  final mes = partes.length == 2 ? int.tryParse(partes[1]) : null;
  if (mes == null || mes < 1 || mes > 12) return aaaaMm;
  return '${_meses[mes - 1]} ${partes[0]}';
}

/// "2026-11" -> "Nov 2026" (para los chips)
String mesCorto(String aaaaMm) {
  final largo = nombreDeMes(aaaaMm);
  final partes = largo.split(' ');
  return partes.length == 2 ? '${partes[0].substring(0, 3)} ${partes[1]}' : largo;
}
