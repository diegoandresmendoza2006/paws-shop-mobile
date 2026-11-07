import '../utils/formato.dart';

/// Una compra ya hecha (GET /compras/mis).
class Orden {
  final int id;
  final double total;
  final String estadoPedido;
  final DateTime? fecha;

  const Orden({required this.id, required this.total, required this.estadoPedido, this.fecha});

  factory Orden.fromJson(Map<String, dynamic> json) => Orden(
        id: json['id'] as int,
        total: (json['total'] as num).toDouble(),
        estadoPedido: json['estado_pedido'] as String,
        fecha: fechaDeApi(json['fecha_compra']),
      );
}
