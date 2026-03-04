class ReservaPedido {
  final int id;
  final int pedidoId;
  final int productoId;
  final double cantidad;

  const ReservaPedido({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.cantidad,
  });
}