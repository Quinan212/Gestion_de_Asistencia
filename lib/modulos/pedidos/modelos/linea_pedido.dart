// lib/modulos/pedidos/modelos/linea_pedido.dart
class LineaPedido {
  final int id;
  final int pedidoId;

  // una línea puede venir de combo o producto directo
  final int? comboId;
  final int? productoId;

  final String nombre; // snapshot (combo o producto)
  final String unidad; // snapshot si es producto; si es combo puede ser "combo"

  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  const LineaPedido({
    required this.id,
    required this.pedidoId,
    required this.comboId,
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  LineaPedido copyWith({
    double? cantidad,
    double? precioUnitario,
    double? subtotal,
    String? nombre,
    String? unidad,
  }) {
    return LineaPedido(
      id: id,
      pedidoId: pedidoId,
      comboId: comboId,
      productoId: productoId,
      nombre: nombre ?? this.nombre,
      unidad: unidad ?? this.unidad,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}