// lib/modulos/pedidos/modelos/pedido.dart
class Pedido {
  final int id;
  final DateTime fecha;
  final String? cliente;
  final String? nota;

  final double envioMonto;
  final String medioPago; // "Efectivo" | "Tarjeta" | "Transferencia"
  final String estadoPago; // "pendiente" | "pagado" | "parcial"

  final PedidoEstado estado;

  final double subtotal;
  final double total;

  final bool stockDescontado;
  final int? ventaId; // se setea al entregar

  const Pedido({
    required this.id,
    required this.fecha,
    required this.cliente,
    required this.nota,
    required this.envioMonto,
    required this.medioPago,
    required this.estadoPago,
    required this.estado,
    required this.subtotal,
    required this.total,
    required this.stockDescontado,
    required this.ventaId,
  });

  bool get cancelado => estado == PedidoEstado.cancelado;
  bool get entregado => estado == PedidoEstado.entregado;
  bool get preparado => estado == PedidoEstado.preparado;

  Pedido copyWith({
    DateTime? fecha,
    String? cliente,
    String? nota,
    double? envioMonto,
    String? medioPago,
    String? estadoPago,
    PedidoEstado? estado,
    double? subtotal,
    double? total,
    bool? stockDescontado,
    int? ventaId,
  }) {
    return Pedido(
      id: id,
      fecha: fecha ?? this.fecha,
      cliente: cliente ?? this.cliente,
      nota: nota ?? this.nota,
      envioMonto: envioMonto ?? this.envioMonto,
      medioPago: medioPago ?? this.medioPago,
      estadoPago: estadoPago ?? this.estadoPago,
      estado: estado ?? this.estado,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      stockDescontado: stockDescontado ?? this.stockDescontado,
      ventaId: ventaId ?? this.ventaId,
    );
  }
}

enum PedidoEstado {
  borrador,
  encargado,
  preparado,
  entregado,
  cancelado,
}

extension PedidoEstadoX on PedidoEstado {
  String get label {
    switch (this) {
      case PedidoEstado.borrador:
        return 'Borrador';
      case PedidoEstado.encargado:
        return 'Encargado';
      case PedidoEstado.preparado:
        return 'Preparado';
      case PedidoEstado.entregado:
        return 'Entregado';
      case PedidoEstado.cancelado:
        return 'Cancelado';
    }
  }

  String get code {
    switch (this) {
      case PedidoEstado.borrador:
        return 'borrador';
      case PedidoEstado.encargado:
        return 'encargado';
      case PedidoEstado.preparado:
        return 'preparado';
      case PedidoEstado.entregado:
        return 'entregado';
      case PedidoEstado.cancelado:
        return 'cancelado';
    }
  }

  static PedidoEstado fromCode(String s) {
    final t = s.trim().toLowerCase();
    switch (t) {
      case 'encargado':
        return PedidoEstado.encargado;
      case 'preparado':
        return PedidoEstado.preparado;
      case 'entregado':
        return PedidoEstado.entregado;
      case 'cancelado':
        return PedidoEstado.cancelado;
      case 'borrador':
      default:
        return PedidoEstado.borrador;
    }
  }
}