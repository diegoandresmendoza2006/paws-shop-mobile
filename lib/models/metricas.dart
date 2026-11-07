/// Los números del panel del administrador (GET /admin/metricas).
class Metricas {
  final String mes;
  final int solicitudesMes;
  final int adopcionesMes;
  final int pedidosMes;
  final double ventasMes;
  final double ventasTotales;
  final int usuariosRegistrados;
  final int usuariosNuevosMes;
  final int mascotasDisponibles;
  final int mascotasAdoptadas;

  const Metricas({
    required this.mes,
    required this.solicitudesMes,
    required this.adopcionesMes,
    required this.pedidosMes,
    required this.ventasMes,
    required this.ventasTotales,
    required this.usuariosRegistrados,
    required this.usuariosNuevosMes,
    required this.mascotasDisponibles,
    required this.mascotasAdoptadas,
  });

  factory Metricas.fromJson(Map<String, dynamic> j) => Metricas(
        mes: j['mes'] as String,
        solicitudesMes: j['solicitudes_mes'] as int,
        adopcionesMes: j['adopciones_mes'] as int,
        pedidosMes: j['pedidos_mes'] as int,
        ventasMes: (j['ventas_mes'] as num).toDouble(),
        ventasTotales: (j['ventas_totales'] as num).toDouble(),
        usuariosRegistrados: j['usuarios_registrados'] as int,
        usuariosNuevosMes: j['usuarios_nuevos_mes'] as int,
        mascotasDisponibles: j['mascotas_disponibles'] as int,
        mascotasAdoptadas: j['mascotas_adoptadas'] as int,
      );
}
