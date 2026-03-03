class LineaVenta {
  final int id;
  final int ventaId;
  final int comboId;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  const LineaVenta({
    required this.id,
    required this.ventaId,
    required this.comboId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });
}