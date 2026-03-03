class LineaCompra {
  final int id;
  final int compraId;
  final int productoId;
  final double cantidad;
  final double costoUnitario;
  final double subtotal;

  const LineaCompra({
    required this.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.costoUnitario,
    required this.subtotal,
  });
}