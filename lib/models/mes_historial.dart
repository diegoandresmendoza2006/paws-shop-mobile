/// Un mes del historial del negocio (GET /admin/metricas/meses).
class MesHistorial {
  final String mes; // '2026-11'
  final String nombre; // 'Noviembre 2026'
  final int solicitudes;
  final int adopciones;
  final int pedidos;
  final double ventas;
  final int usuariosNuevos;

  const MesHistorial({
    required this.mes,
    required this.nombre,
    required this.solicitudes,
    required this.adopciones,
    required this.pedidos,
    required this.ventas,
    required this.usuariosNuevos,
  });

  factory MesHistorial.fromJson(Map<String, dynamic> j) => MesHistorial(
        mes: j['mes'] as String,
        nombre: j['nombre'] as String,
        solicitudes: j['solicitudes'] as int,
        adopciones: j['adopciones'] as int,
        pedidos: j['pedidos'] as int,
        ventas: (j['ventas'] as num).toDouble(),
        usuariosNuevos: j['usuarios_nuevos'] as int,
      );
}
